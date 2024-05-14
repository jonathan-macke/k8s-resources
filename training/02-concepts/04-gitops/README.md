# GitOps


GitOps is a modern operational model introduced by Weaveworks for managing infrastructure and applications using **Git as the single source of truth**

Its main characteristics:
* **Infrastructure as Code (IaC)**: Infrastructure configurations, such as Kubernetes manifests, are stored in a Git repository. These configurations describe the desired state of the infrastructure.
* **Deployment Automation**: CI/CD pipelines (integrated directly into k8s cluster) are set up to automate the deployment process. These pipelines monitor changes in the Git repository and automatically apply them to the target environment whenever a change is detected. 
* **Pull-Based Model**: In GitOps, the target environment continuously syncs with the Git repository to converge its state with the desired state described in the repository.


Two major solutions to implement GitOps on k8s:
* Flux CD: see section about FluxCD
* Argo CD: not covered by this training