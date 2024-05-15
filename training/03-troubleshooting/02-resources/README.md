# Troubleshoot pod resource


Create a namespace `02-resources`

```shell
kubectl create namespace 02-resources
kubens 02-resources
kubectl apply -f pod.yaml
```


## Exercise

Identify the **two** issues in the k8s manifests

Use `kubectl describe` to investigate
