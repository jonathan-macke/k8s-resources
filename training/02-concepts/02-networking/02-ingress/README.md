# Ingress

## 1. What is an Ingress

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. 
Traffic routing is controlled by rules defined on the Ingress resource.

> [!NOTE]
> Ingress API is frozen. It will be replaced by a new API named [Gateway](https://kubernetes.io/docs/concepts/services-networking/gateway/)

![Ingress](../../../assets/ingress.png "Ingress")

An Ingress resource comes together with an **Ingress controller**. 
An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer. 
Solution for **Ingress controller** depends on the platform on which the cluster is deployed. 

See https://cloud.google.com/kubernetes-engine/docs/concepts/ingress for more info about Ingress in Google Kubernetes Engine.


## 2. Test environment

Use the same environment as the lab about services

All practical works will done within the namespace `workload`

