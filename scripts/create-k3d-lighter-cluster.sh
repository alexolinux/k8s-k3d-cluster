#!/bin/bash

set -e

VOLUME_PATH="${HOME}/kubernetes/volume"
SERVERS=1
AGENTS=2
API_PORT=6550
PORT=8000

read -p "Enter the desired name for your K3d cluster (e.g., kubelight): " K3D_NAME

if [ -z "${K3D_NAME}" ]; then
  echo "Error: Cluster name cannot be empty. Exiting."
  exit 1
fi

echo "---"
echo "Ensuring volume directory exists at: ${VOLUME_PATH}"
mkdir -p "${VOLUME_PATH}"
echo "Volume directory checked/created."
echo "---"

echo "Creating ${K3D_NAME} cluster with ${SERVERS} server and ${AGENTS} agents..."
echo "This might take a few moments..."

k3d cluster create "${K3D_NAME}" \
  --servers "${SERVERS}" \
  --agents "${AGENTS}" \
  --k3s-node-label topology.kubernetes.io/zone=zone-a@agent:0 \
  --k3s-node-label topology.kubernetes.io/zone=zone-a@agent:1 \
  --api-port "${API_PORT}" \
  -p "${PORT}:80@loadbalancer" \
  --volume "${VOLUME_PATH}:/data@agent:*"

echo "---"
if [ $? -eq 0 ]; then
    echo "SUCCESS: K3d cluster '${K3D_NAME}' created successfully!"
    echo "Now, tainting the control plane node to prevent it from running Pods."

    # Give the cluster a moment to fully initialize the control plane node
    echo "Waiting for control plane node to be ready..."
    sleep 5

    # Get the control plane node name dynamically
    CONTROL_PLANE_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[*].metadata.name}')

    if [ -z "$CONTROL_PLANE_NODE" ]; then
        echo "ERROR: Could not find the control plane node. Please check your cluster."
        exit 1
    fi

    echo "Tainting node: ${CONTROL_PLANE_NODE}"
    kubectl taint nodes "${CONTROL_PLANE_NODE}" node-role.kubernetes.io/control-plane:NoSchedule

    if [ $? -eq 0 ]; then
        echo "Control plane node '${CONTROL_PLANE_NODE}' tainted successfully."
        echo "Your '${K3D_NAME}' cluster is now ready for use, with deployments scheduled only on agent nodes."
        echo "Try: kubectl get nodes -o wide"
    else
        echo "ERROR: Failed to taint the control plane node."
        exit 1
    fi
else
    echo "ERROR: Failed to create K3d cluster '${K3D_NAME}'."
    exit 1
fi

echo "---"
echo "To delete this cluster, run: k3d cluster delete ${K3D_NAME}"
echo "To check your kubectl contexts, run: kubectl config get-contexts"
echo "---"
