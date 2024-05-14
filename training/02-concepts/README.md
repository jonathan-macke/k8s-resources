# Concepts


We will go through the major concepts in k8s:
* 01 - Workload deployment (pod & job): liveness / readiness, rollout strategy, pod lifecycle, pod disruption budget & node affinity
* 02 - Network: service & ingress
* 03 - Secret: integration with Vault, external secrets
* 04 - GitOps: with FluxCD & kustomize



# Prerequisites

Make sure you have a clean environment

**No cluster setup**
```shell
minikube profile list

🤹  Exiting due to MK_USAGE_NO_PROFILE: No minikube profile was found.
```

**No running Docker containers**
```shell
docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```


# Environment setup

The Workload, Networking and Secret sections will rely on a unique k8s cluster named **prod** you can setup using the script `<project-root>/infra/setup.sh`

Flux CD will require an additional cluster in order to simulate preprod and prod deployment.


After running `<project-root>/infra/setup.sh`, you can control your cluster is OK

**Show the active Minikube profile**
```shell
minikube profile list
|---------|-----------|---------|--------------|------|----------|---------|-------|----------------|--------------------|
| Profile | VM Driver | Runtime |      IP      | Port | Version  | Status  | Nodes | Active Profile | Active Kubecontext |
|---------|-----------|---------|--------------|------|----------|---------|-------|----------------|--------------------|
| prod    | docker    | docker  | 192.168.49.2 | 8443 | v1.27.13 | Running |     3 |                | *                  |
|---------|-----------|---------|--------------|------|----------|---------|-------|----------------|--------------------|
```

**Display nodes**
```shell
kubectl get nodes
NAME       STATUS   ROLES           AGE     VERSION
prod       Ready    control-plane   4m      v1.27.13
prod-m02   Ready    <none>          3m40s   v1.27.13
prod-m03   Ready    <none>          3m27s   v1.27.13
```

```shell
kubectl get pods --all-namespaces
NAMESPACE          NAME                                               READY   STATUS    RESTARTS        AGE
external-secrets   external-secrets-56867d5968-8drcq                  1/1     Running   0               3m50s
external-secrets   external-secrets-cert-controller-6c8bc74d8-6xhw5   1/1     Running   0               3m50s
external-secrets   external-secrets-webhook-6d5dd77dcf-95qzj          1/1     Running   0               3m50s
kube-system        coredns-5d78c9869d-zsvd7                           1/1     Running   1 (4m16s ago)   4m31s
kube-system        etcd-prod                                          1/1     Running   0               4m44s
kube-system        kindnet-mzcgm                                      1/1     Running   0               4m14s
kube-system        kindnet-qm4f5                                      1/1     Running   0               4m27s
kube-system        kindnet-xfqww                                      1/1     Running   0               4m31s
kube-system        kube-apiserver-prod                                1/1     Running   0               4m44s
kube-system        kube-controller-manager-prod                       1/1     Running   0               4m45s
kube-system        kube-proxy-gswgk                                   1/1     Running   0               4m27s
kube-system        kube-proxy-k72mw                                   1/1     Running   0               4m31s
kube-system        kube-proxy-x5mfj                                   1/1     Running   0               4m14s
kube-system        kube-scheduler-prod                                1/1     Running   0               4m44s
kube-system        storage-provisioner                                1/1     Running   1 (4m19s ago)   4m43s
postgresql         db-7f4c94884f-7f56f                                1/1     Running   0               3m19s
vault              vault-0                                            1/1     Running   0               4m13s
vault              vault-agent-injector-d986fcb9b-xrqpz               1/1     Running   1 (4m6s ago)    4m13s
```

