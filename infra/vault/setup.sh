#!/bin/sh

NAMESPACE="vault"
POD_NAME="vault-0"
SECRET_ENGINE="test"
SECRET="config"

createNamespace() {
    if kubectl get namespace $1 &> /dev/null; then
        echo "Namespace $1 already exists."
    else
        kubectl create namespace $1
        echo "Namespace $1 created successfully."
    fi
}

createNamespace $NAMESPACE


helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault --namespace $NAMESPACE -f helm-vault-dev-values.yml


check_helm_deployed() {
    if helm status vault -n $NAMESPACE -o json | jq '.info.status' | grep -q "deployed"; then
        return 0 
    else
        return 1 
    fi
}

while ! check_helm_deployed; do
    echo "Waiting for helm chart to be deployed..."
    sleep 5
done


check_pod_ready() {
    if kubectl get pod -n $NAMESPACE $POD_NAME &> /dev/null; then
        if kubectl get pod -n $NAMESPACE $POD_NAME -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
            return 0 # Pod is ready
        else
            return 1 # Pod is not ready yet
        fi
    else
        return 2 # Pod not found
    fi
}

while ! check_pod_ready; do
    echo "Waiting for pod to be ready..."
    sleep 5
done
echo "Pod is now ready"

# add an new secret engine
kubectl exec -t $POD_NAME -n $NAMESPACE -- vault secrets enable -path=$SECRET_ENGINE kv-v2

# add a new value in the secret engine
kubectl exec -t $POD_NAME -n $NAMESPACE -- vault kv put -mount=$SECRET_ENGINE $SECRET pwd=changeme

minikube service vault -n $NAMESPACE


