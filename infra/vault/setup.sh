#!/bin/sh

NAMESPACE="vault"
POD_NAME="vault-0"
SECRET_ENGINE="test"
SECRET="config"

source ../util/utils.sh

createNamespace $NAMESPACE

helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --namespace $NAMESPACE -f helm-vault-dev-values.yml

check_helm_deployed $NAMESPACE

check_pod_ready $NAMESPACE $POD_NAME

# add an new secret engine
kubectl exec -t $POD_NAME -n $NAMESPACE -- vault secrets enable -path=$SECRET_ENGINE kv-v2

# add a new value in the secret engine
kubectl exec -t $POD_NAME -n $NAMESPACE -- vault kv put -mount=$SECRET_ENGINE $SECRET pwd=changeme




