#!/bin/bash

set -e

VOLUME_PATH="${HOME}/kubernetes/volume"
SERVERS=3
AGENTS=3
API_PORT=6550
PORT=8000

read -p "Enter the desired name for your K3d cluster (e.g., kubelab): " K3D_NAME

if [ -z "${K3D_NAME}" ]; then
  echo "Error: Cluster name cannot be empty. Exiting."
  exit 1
fi

echo "---"
echo "Ensuring volume directory exists at: ${VOLUME_PATH}"
mkdir -p "${VOLUME_PATH}"
echo "Volume directory checked/created."
echo "---"

echo "Creating ${K3D_NAME} cluster with ${SERVERS} servers and ${AGENTS} agents..."
echo "This might take a few moments..."

k3d cluster create "${K3D_NAME}" \
  --servers "${SERVERS}" \
  --agents "${AGENTS}" \
  --k3s-node-label topology.kubernetes.io/zone=zone-a@agent:0 \
  --k3s-node-label topology.kubernetes.io/zone=zone-a@agent:1 \
  --k3s-node-label topology.kubernetes.io/zone=zone-a@agent:2 \
  --api-port "${API_PORT}" \
  -p "${PORT}:80@loadbalancer" \
  --volume "${VOLUME_PATH}:/data@agent:*"

echo "---"
if [ $? -eq 0 ]; then
  echo "SUCCESS: K3d cluster '${K3D_NAME}' created successfully!"
  echo "Now, tainting the control plane nodes to prevent them from running Pods."

  # Give the cluster a moment to fully initialize the control plane nodes
  echo "Waiting for control plane nodes to be ready..."
  sleep 10 # Increased sleep to account for multiple servers coming up

  # Get all control plane node names dynamically
  CONTROL_PLANE_NODES=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane=="")].metadata.name}' | head -n 1)

  if [ -z "$CONTROL_PLANE_NODES" ]; then
      echo "WARNING: Could not find any control plane nodes. Tainting skipped."
  else
      for NODE in ${CONTROL_PLANE_NODES}; do
          echo "Tainting node: ${NODE}"
          kubectl taint nodes "${NODE}" node-role.kubernetes.io/control-plane:NoSchedule
          if [ $? -ne 0 ]; then
              echo "WARNING: Failed to taint node '${NODE}'. Continuing with other nodes."
          fi
      done
      echo "Control plane nodes tainted successfully."
      echo "Your '${K3D_NAME}' cluster is now ready for use, with deployments preferentially scheduled on agent nodes."
  fi
  echo "Try: kubectl get nodes -o wide"
else
  echo "ERROR: Failed to create K3d cluster '${K3D_NAME}'."
  exit 1
fi

echo "---"
echo "To delete this cluster, run: k3d cluster delete ${K3D_NAME}"
echo "To check your kubectl contexts, run: kubectl config get-contexts"
echo "---"
