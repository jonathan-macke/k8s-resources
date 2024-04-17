# Deployment

## What is a Deployment 
A Deployment is a higher-level resource meant for deploying applications and
updating them declaratively, it relies on Pod and ReplicaSet 

**Documentation**: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/


Deployment covers the following aspects
- define the containers to be part of the pod 
- define how many replicas we want for the pod
- define rollout strategy (ie. when deploying new version of the pod)
- define volumes linked to the pod
- define the resources (CPU & memory) required to run the pod
- define the node affinity (ie. node scheduling)
- define pod lifecyle
- define security policies


## Deployment definition

### Deployment spec

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <app-name>
  namespace: <namespace>
spec:
  replicas: <nb-of-replicas>
  selector:               # provide selector to find which pods to manage
  template:               # pod template (define one or more containers)
    metadata:             # define labels and annotations for the pod
    spec:                 # pod spec
```

### Pod spec

**Reference**: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec)
```
spec:
  initContainers:     # List of initialization 
  containers belonging to the pod.
    - <init container 1>
    - <init container 2>
  imagePullSecrets:  
  imagePullSecrets:
    - name: regcred-gar
   #  
  containers:
    - <container 1>   # see Container spec
    - <container 2>
```

### Container spec


**Reference**: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container
```
name: <container-name>
image: <image-name>
imagePullPolicy: Never
env:            # env variables
livenessProbe:
readinessProbe:
resources:
```


## Create a first deployment

Practical work will done in a namespace `workload``


### Exercise

We will create a nginx pod to serve HTML pages. 
The first step is to deploy a default nginx

```
kubectl create namespace workload
kubens workload
```


```
kubectl apply -f deployment.yaml
pod_name=$(kubectl get pods -l app=app -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $pod_name
```



Try to access the pod
```
pod_ip=$(k get pods $pod_name -o jsonpath='{.status.podIP}')
curl http://$pod_ip --verbose
```

Port forwarding
```
kubectl port-forward $pod_name 8080:80
curl http://localhost:8080 --verbose
```


## Liveness / Readiness

**Documentation**: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

Kubernetes can check if a container is still alive through **liveness probes**. You can specify
a liveness probe for each container in the pod’s specification. Kubernetes will periodically
execute the probe and restart the container if the probe fails.

The **readiness probe** is invoked periodically and determines whether the specific
pod should receive client requests or not. When a container’s readiness probe returns
success, it’s signaling that the container is ready to accept requests


### Exercise

If liveness and readiness are not defined, Kubernetes will default to using a simple TCP socket check to determine if the container is ready and still alive.

In this practical work, we would like to make sure our NGINX is ready when it can deliver a *test.html*

We will use a ConfigMap to store our test.html

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-html
  namespace: workload
data:
  test.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Page</title>
    </head>
    <body>
        <h1>Hello, World!</h1>
        <p>This is a test HTML page served by Nginx in Kubernetes.</p>
    </body>
    </html>
```

You need:
- setup volume mount in the Deployment to make the test.html available to nginx
- setup readiness probe to periodically check that HTTP call to test.html is OK
- setup liveness probe to check periodically that HTTP call to / is OK




## Rollout strategy


