# Troubleshoot secret

The application is a simple Java main program that tries to connect the postgresql database defined in infra folder.

When the application has managed to connect, it simply dumps a log in the standard output

## Setup

``` shell
./setup.sh
```

Pod should not start
``` shell
k get pods
NAME                   READY   STATUS                       RESTARTS   AGE
app-7b7959884d-8ks4f   0/1     CreateContainerConfigError   0          39s
```



## Exercise

Identify the **two** issues in the k8s manifests

Use `kubectl describe` to investigate
