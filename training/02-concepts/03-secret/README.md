# Secret

This section will cover **k8s Secret** and **External Secret** connected to Vault

**What you will learn**
- import Vault secret as k8s secret
- Use secret as env variable or file 

**Sample application**

The application is a Java main application that dumps the content of a Java keystore. 

It requires the following information stored in Vault:
- a keystore password
- a keystore stored in Base64

## k8s secret



## External secret

External Secrets Operator synchronizes secrets from external APIs like Vault into Kubernetes

**Documentation**: https://external-secrets.io/latest/

It supports the following k8s resources:
- ExternalSecret: 
- SecretStore: create connection with the external secret management system


Example of SecretStore with Vault by using token-based authentication. Usually SecretStore is defined by Ops team.
``` yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://my.vault.server:8200"
      path: "secret"
      # Version is the Vault KV secret engine version.
      # This can be either "v1" or "v2", defaults to "v2"
      version: "v2"
      auth:
        # points to a secret that contains a vault token
        # https://www.vaultproject.io/docs/auth/token
        tokenSecretRef:
          name: "vault-token"
          key: "token"
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
data:
  token: cm9vdA== # "root"
```



``` shell
kubectl get pods
NAME                                                READY   STATUS    RESTARTS   AGE
external-secrets-cert-controller-658ddcb44b-9rxst   1/1     Running   0          154m
external-secrets-d7857bc5d-qhtzg                    1/1     Running   0          154m
external-secrets-webhook-54b7b9d4df-ctwq4           1/1     Running   0          154m
```


## Exercice

``` shell
./setup.sh
```

The pod should not start
``` shell
kubectl get pods
NAME                  READY   STATUS             RESTARTS      AGE
app-8d796f9c4-56dqn   0/1     CrashLoopBackOff   2 (21s ago)   39s
```


You can use `kubectl describe` for troubleshooting



