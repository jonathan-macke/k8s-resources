# Deployment

## 1. What is a Deployment 
A Deployment is a higher-level resource meant for deploying applications and
updating them declaratively, it relies on Pod and ReplicaSet 

**Documentation**: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/


Deployment covers the following aspects
- define the containers to be part of the pod 
- define how many replicas we want for the pod
- define volumes linked to the pod
- define the readiness and liveness
- define rollout strategy (ie. when deploying new version of the pod)
- define the resources (CPU & memory) required to run the pod
- define the node affinity (ie. node scheduling)
- define pod lifecyle
- define security policies


## 2. Deployment definition

### 2.1. Deployment spec

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <app-name>
  namespace: <namespace>
spec:
  replicas: <nb-of-replicas>
  selector:               # provide selector to find which pods to manage
  strategy:               # define rollout strategy
  template:               # pod template (define one or more containers)
    metadata:             # define labels and annotations for the pod
    spec:                 # pod spec
```

### 2.2. Pod spec

**Reference**: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec)
```yaml
spec:
  initContainers:     # List of initialization 
  containers belonging to the pod.
    - <init container 1>
    - <init container 2>
  imagePullSecrets:
    - name: regcred-gar
  volumes: 
  containers:
    - <container 1>   # see Container spec
    - <container 2>
```

### 2.3. Container spec


**Reference**: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container
```yaml
name: <container-name>
image: <image-name>
imagePullPolicy: Never
env:            # env variables
livenessProbe:
readinessProbe:
resources:
volumeMounts:
```


## 3. Test environment

We will use a multi-node cluster. 
If not yet done, you can setup the cluster with the script located in `<project-root>/infra/setup.sh`

All exercises will be done with NGINX which is web server. See https://nginx.org/en/docs/
We will nginx Docker image from Docker Hub.

All practical works will done in a namespace `workload`

```shell
kubectl create namespace workload
kubens workload
```


## 4. Create a first deployment


### 4.1. Exercise

We will create a nginx pod to serve HTML pages. 
The first step is to deploy a default nginx


```shell
kubectl apply -f deployment.yaml
pod_name=$(kubectl get pods -l app=app -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $pod_name
```


**output of the describe**
```shell
Name:             app-5c748bc747-jcvhq
Namespace:        workload
Priority:         0
Service Account:  default
Node:             prod-m03/192.168.49.4
Start Time:       Tue, 14 May 2024 11:10:22 +0200
Labels:           app=app
                  pod-template-hash=5c748bc747
Annotations:      <none>
Status:           Running
IP:               10.244.2.5
IPs:
  IP:           10.244.2.5
Controlled By:  ReplicaSet/app-5c748bc747
Containers:
  app:
    Container ID:   docker://1646e2da855ee78e2947cfcf2980e5d8fbf9f9e585f3736342e666d3850ce0ff
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:32e76d4f34f80e479964a0fbd4c5b4f6967b5322c8d004e9cf0cb81c93510766
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 14 May 2024 11:10:30 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gjfts (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-gjfts:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m56s  default-scheduler  Successfully assigned workload/app-5c748bc747-jcvhq to prod-m03
  Normal  Pulling    6m55s  kubelet            Pulling image "nginx:latest"
  Normal  Pulled     6m49s  kubelet            Successfully pulled image "nginx:latest" in 6.616560208s (6.61657275s including waiting)
  Normal  Created    6m49s  kubelet            Created container app
  Normal  Started    6m48s  kubelet            Started container app
```



**Try to access the pod**
```shell
pod_ip=$(kubectl get pods $pod_name -o jsonpath='{.status.podIP}')
curl http://$pod_ip --verbose
```


**Port forwarding**
```shell
kubectl port-forward $pod_name 8080:80
curl http://localhost:8080 --verbose
```


**Can view logs from the pod**
```shell
kubectl logs $pod_name
```

**Can SSH into the pod**
```shell
kubectl exec -ti $pod_name -- bash
```


## 5. Replica

When setting the `replica` property, k8s will always try  to ensure that the nb of pods matches the expected replica


**Display Deployment (see how many replicas are ready)**
```shell
kubectl get deploy
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
app    2/2     2            2           3h18m
```

**wide display**
```shell
kubectl get deploy -o wide
NAME   READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES         SELECTOR
app    2/2     2            2           3h21m   app          nginx:latest   app=app
```

**View on which pods have been scheduled**
```shell
k get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE    IP           NODE       NOMINATED NODE   READINESS GATES
app-54c475df46-4pv8v   1/1     Running   0          127m   10.244.2.6   prod-m03   <none>           <none>
app-54c475df46-sfpws   1/1     Running   0          13m    10.244.1.6   prod-m02   <none>           <none>
```

### 5.1. Exercise

Change replica in deployment.yaml to 3 and redeploy.

We can scale up or down using CLI

```shell
kubectl scale --replicas=2 deploy/app
kubectl scale --replicas=0 deploy/app   #no more pod
```


## 6. Volume

In the previous section, we simply showed the default HTML index page proposed by NGINX

The target for this section is to add a **test.html** page so that http://localhost:8080/test.html does not return a 404
We will see how to:
- configure a configmap to store the test.html page
- configure the volume in Deployment so that the test.html page is stored at the correct folder

### 6.1. ConfigMap

A ConfigMap is an API object used to store non-confidential data in key-value pairs.
Pods can consume ConfigMaps as:
* environment variables,
* command-line arguments, 
* configuration files in a volume.

**Documentation**: https://kubernetes.io/docs/concepts/configuration/configmap/

**Example**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  # property-like keys; each key maps to a simple value
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  # file-like keys
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5    
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true 
```


### 6.2. Volume mount

In order to mount a volume in the container filesystem, you have to:
1. Declare the volume at pod level and map it with the configmap
2. At container level, mount this volume with a particular path inside the container.


**Declare volume at pod level**
```yaml
spec:
  replicas: 2
  selector:
  template:
    spec:
      volumes:
        - name: <unique-name-inside-deployment>
          configMap:
            name: <configmap-name>
      containers:
```

**Mounting the volume inside the container**
```yaml
containers:
  - name: myapp
    image: myimage
    volumeMounts:
    - name: <same-name-as-the-one-define-in-pod>
      mountPath: "<path-inside-container>"
```


### 6.3. Exercise

Use this ConfigMap to store our test.html

```yaml
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

Setup volume mount in the Deployment to make the test.html available to nginx. 
By default nginx expects html files to be located in `/usr/share/nginx/html`


## 7. Readiness / Liveness

**Documentation**: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

### 7.1. Readiness

The **readiness probe** is invoked periodically and determines whether the specific
pod should receive client requests or not. When a container’s readiness probe returns
success, it’s signaling that the container is ready to accept requests


Example
```yaml
spec:
  containers:
  - name: myapp
    image: myimage
    readinessProbe:
      httpGet:
        path: /<path>
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 3
```

initialDelaySeconds = duration in seconds before performing the first probe
periodSeconds = How often (in seconds) to perform the probe

### 7.2. Liveness


Kubernetes can check if a container is still alive through **liveness probes**. You can specify
a liveness probe for each container in the pod’s specification. Kubernetes will periodically
execute the probe and restart the container if the probe fails.


Example
```yaml
spec:
  containers:
  - name: myapp
    image: myimage
    livenessProbe:
      httpGet:
        path: /<path>
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 3
```


### 7.3. Exercise

If liveness and readiness are not defined, Kubernetes will consider your pods as healthy all the time

In this practical work, we would like to make sure our NGINX is ready when it can deliver a *test.html*


You need:
- setup readiness probe to periodically check that HTTP call to test.html is OK
- setup liveness probe to check periodically that HTTP call to / is OK




## 8. Rollout strategy

Rollout refers to the deployment strategy used to replace existing pods with new ones.

Two possible strategies:
* Recreate
* RollingUpdate. Default option

With **recreate** strategy, all existing Pods are killed before new ones are created. This strategy generates downtime.

A **rolling update** allows a Deployment update to take place with zero downtime. It does this by incrementally replacing the current Pods with new ones.
The new Pods are scheduled on Nodes with available resources, and Kubernetes waits for those new Pods to start before removing the old Pods. 
In order to support this strategy, your application has to support multiple versions running at the same time.

You can specify **maxUnavailable** and **maxSurge** to control the rolling update process. 
The value can be an *absolute number* (for example, 5) or a *percentage* of desired Pods (for example, 10%). Default value for both is 25%.

**maxSurge**: This parameter defines the maximum number of pods that can be created over the desired number of pods during a rolling update.
**maxUnavailable**: This parameter specifies the maximum number or percentage of pods that can be unavailable during the rolling update process.

Example with *replica = 10*, *maxSurge = 2* and *maxUnavailable = 1*, it means that 
- maximum 12 pods (replica + maxSurge) can be created  
- minimum 9 pods must be available (replica - maxUnavailable) 


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: nginx-deployment
 labels:
   app: nginx
spec:
 replicas: 3
 selector:
 template:
   spec:
     containers:
     - name: myapp
       image: myimage
 strategy:
   type: RollingUpdate
   rollingUpdate:
     maxSurge: 2
     maxUnavailable: 1

```

### 8.1. Exercise

Change rollout strategy to Recreate and change nginx image version (eg: `nginx:1.26.0-bookworm`)

Run describe on Deployment
```shell
kubectl describe deploy app
```

Notice the scale down to 0. All pods are killed at the same time. It scales down all the pod, then scales them up.
```shell
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m19s  deployment-controller  Scaled down replica set app-77f446dcd to 0 from 2
  Normal  ScalingReplicaSet  2m18s  deployment-controller  Scaled up replica set app-775cfd85f7 to 2
```


Change the rollout strategy to RollingUpdate and change nginx image version

Again run again the describe on Deployment

You should notice the scale up/down is done 1 by 1
```shell
  Normal  ScalingReplicaSet  6s    deployment-controller  Scaled up replica set app-77f446dcd to 1 from 0
  Normal  ScalingReplicaSet  4s    deployment-controller  Scaled down replica set app-5d5dcffcdf to 1 from 2
  Normal  ScalingReplicaSet  4s    deployment-controller  Scaled up replica set app-77f446dcd to 2 from 1
  Normal  ScalingReplicaSet  2s    deployment-controller  Scaled down replica set app-5d5dcffcdf to 0 from 1
```



## 9. Resources

There are two different types of resource configurations: requests and limits

**requests** : define the minimum amount of resources that containers need. Requests affect how the pods are scheduled in Kubernetes (used by kube-scheduler)
**limits**: define the max amount of resources that the container can consume. Used by kubelet to kill pod in case it reachs its limit

Kubernetes has several components designed to collect metrics, but two are essential in this case:

* The kubelet is a process running on each nodes of the cluster. It collects metrics such as CPU and memory from your Pods.
* The metric server collects and aggregates metrics from all kubelets.

Resources is configured for each container of the pod. 
```yaml
containers:
- name: cpu-demo-ctr-2
  image: vish/stress
  resources:
    limits:
      cpu: "1"
      memory: "200Mi"
    requests:
      cpu: "500m"
      memory: "100Mi"
```

**Documentation**: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#resources

> [!CAUTION]
> Resources cannot be updated. Therefore, you must delete the deployment in order to update its compute resources

### 9.1. Exercise

Try to put a high CPU request (eg. "100") and see what happens when deploying
```yaml
kubectl delete deploy app
kubectl apply -f deployment.yaml
```

Try to put low memory request & limit and see what happens when deploying
```yaml
kubectl delete deploy app
kubectl apply -f deployment.yaml
```


## 10. Node affinity



## Security policy
