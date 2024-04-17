#!/bin/sh

NAMESPACE=external-secrets

helm repo add external-secrets https://charts.external-secrets.io

if helm list -n external-secrets -o json | jq '.[] | select(.name == "external-secrets").status' | grep -q "deployed"; then
    echo "external-secret chart already deployed"
else 
    helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
fi

pod_names=$(kubectl get pods -n "$NAMESPACE" -o=jsonpath='{.items[*].metadata.name}')

# Convert the space-separated string of pod names into an array
read -ra pod_array <<<"$pod_names"

for pod_name in "${pod_array[@]}"; do
    echo "Waiting for pod $pod_name to be ready..."
    until kubectl wait --for=condition=Ready pod/"$pod_name" -n "$NAMESPACE" --timeout=300s; do
        echo "Pod $pod_name is not ready yet, waiting..."
        sleep 10
    done
    echo "Pod $pod_name is ready."
done

kubectl apply -f vault-secret-store.yaml

if kubectl get ss -n $NAMESPACE vault-secret-store -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
    echo "secret store ready" 
else
    kubectl describe ss -n $NAMESPACE vault-secret-store
fi

