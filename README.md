# k8s-k3d-cluster

-----------------

A simple and efficient way to create and manage Kubernetes clusters using k3d.

## What is k3d?

**[K3d](https://k3d.io/)** is a lightweight wrapper that runs **[K3s](https://docs.k3s.io/)** in Docker.

## 👤 Who is this lab for?

For those who do not have a local environment with a large capacity. Such as creating multiple instances, whether VMs, cloud, etc.

This repository provides scripts and documentation for setting up a Kubernetes cluster using K3d, tailored for CKA/CKAD practice.

## ⚙️ Requirements

* [`curl`](https://curl.se/docs/tutorial.html) command
* [Docker](https://docs.docker.com/engine/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

## 🚢 K3d Installation

To install `k3d`, run the following command:

```shell
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Based on [k3d.io](https://k3d.io/stable/)

## K3d Customization

### Local Volume Directory

K3d script will create the following directory, where your cluster can store persistent data *(you can change this directory of your choice by editing the script)*:

```shell
"${HOME}/kubernetes/volume"
```

### Taints and Tolerations

The script is designed to schedule deployments only on the worker nodes by tainting the control-plane(s).

## K3d Cluster Creation: Let's roll

### **Option A**: Robust K3d Cluster

This setup is ideal for mimicking a more robust, highly available Kubernetes environment. It includes multiple control plane nodes and worker nodes, perfect for practicing failovers and advanced scheduling. It creates:

* 3 control-planes
* 3 worker nodes

To create this cluster, run the following script:

```shell
./scripts/create-k3d-cluster.sh

Example:

```output
kubectl get nodes
NAME                STATUS   ROLES                       AGE   VERSION
k3d-ckad-server-0   Ready    control-plane,etcd,master   15m   v1.31.5+k3s1
k3d-ckad-server-1   Ready    control-plane,etcd,master   15m   v1.31.5+k3s1
k3d-ckad-server-2   Ready    control-plane,etcd,master   14m   v1.31.5+k3s1
k3d-ckad-agent-0    Ready    <none>                      14m   v1.31.5+k3s1
k3d-ckad-agent-1    Ready    <none>                      14m   v1.31.5+k3s1
k3d-ckad-agent-2    Ready    <none>                      14m   v1.31.5+k3s1
```

### **Option B**: Lighter K3d Cluster

In lighter environments, you might to have a single control-plane and fewer agents. It creates:

* 1 control-plane
* 2 worker nodes

To create this cluster, run the following script:

```shell
./scripts/create-k3d-lighter-cluster.sh
```

Example:

```output
kubectl get nodes

NAME               STATUS   ROLES                  AGE   VERSION
k3d-k8s-server-0   Ready    control-plane,master   48s   v1.29.6+k3s2
k3d-k8s-agent-0    Ready    <none>                 41s   v1.29.6+k3s2
k3d-k8s-agent-1    Ready    <none>                 40s   v1.29.6+k3s2

```

### Arguments

* `--servers 3`

This option specifies that the cluster should have 3 server nodes (control-plane). In Kubernetes, control-planes nodes are responsible for managing the cluster and running key services such as the API server, scheduler, and controller manager.

* `--agents 3`

This specifies that the cluster should have 3 agent nodes (also known as worker nodes). These are responsible for running the application workloads (Pods).

* `--k3s-node-label topology.kubernetes.io/zone=zone-a@agent:*`

This sets a Kubernetes node label on *each agent nodes*. The label topology.kubernetes.io/zone=zone-a helps identify that this agent is part of "zone-a". Labels can be used later for things like scheduling workloads to specific zones for availability.

* `--api-port 6550`

`--api-port $port` specifies that the Kubernetes API should be accessible via port 6550 on the host machine. If you want to interact with the cluster using kubectl or any other Kubernetes management tool, this is the port to use.

* `-p "8000:80@loadbalancer"`

This `-p` or `--port` sets up port forwarding from the host machine to the cluster. In this case, it's mapping port 8000 on the host machine to port 80 on the load balancer node inside the k3d cluster. This is useful for exposing applications running in the cluster to the outside world. Feel free to change this port.

* `--volume "${HOME}/kubernetes/volume:/data@agent:*"`

This mounts a volume from your local machine (${HOME}/kubernetes/volume) to the /data directory on all agent nodes (@agent:*). The * indicates that this volume should be mounted on all agent nodes. This is useful for sharing data between your host and the Kubernetes cluster's worker nodes.

### References

* https://k3d.io/v5.8.3/usage/exposing_services/
* https://k3d.io/v5.8.3/usage/commands/k3d_registry_create/?h=volume
* https://k3d.io/v5.8.3/usage/configfile/
* https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
* https://kubernetes.io/docs/concepts/configuration/

### Author

[Alex Mendes](https://alexolinux.com)

https://www.linkedin.com/in/mendesalex
