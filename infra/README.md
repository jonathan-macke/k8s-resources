# Setup local k8s cluster


Includes following components:
- Vault
- External-secrets
- FluxCD
- PostgreSQL


## Prerequisite

Must install:
- kubectl
- helm
- minikube



# Setup 

Run the script *setup.sh*
```shell
 chmod +x setup.sh
 ./setup.sh 
```


# Clean
You can clean your entire cluster using the *clean.sh* script

```shell
 chmod +x clean.sh
 ./clean.sh 
```