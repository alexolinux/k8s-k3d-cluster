# k8s-k3d-cluster

-----------------

Simple and efficient way to create and manage Kubernetes clusters using k3d.

## Who is this lab for?

For those who do not have a local environment with a large capacity. Such as creating multiple instances, whether VMs, cloud, etc.

This repository provides scripts and documentation for setting up a Kubernetes cluster using K3d, tailored for CKA/CKAD practice.

## Requirements

* [`curl`](https://curl.se/docs/tutorial.html) command
* [Docker](https://docs.docker.com/engine/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

## K3d Installation

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

## Cluster Creation: Let's roll

### **Option A**: Robust K3d Cluster

This setup is ideal for mimicking a more robust, highly available Kubernetes environment. It includes multiple control plane nodes and worker nodes, perfect for practicing failovers and advanced scheduling. It creates:

* 3 control-planes
* 3 worker nodes

To create this cluster, run the following script:

```shell
./scripts/create-ckad-cluster.sh
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
k3d-k8s-agent-2    Ready    <none>                 41s   v1.29.6+k3s2
```

### References

* https://k3d.io/v5.8.3/usage/exposing_services/
* https://k3d.io/v5.8.3/usage/commands/k3d_registry_create/?h=volume
* https://k3d.io/v5.8.3/usage/configfile/
* https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
* https://kubernetes.io/docs/concepts/configuration/

### Author

[Alex Mendes](https://alexolinux.com)

https://www.linkedin.com/in/mendesalex
