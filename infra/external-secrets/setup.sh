#!/bin/sh

source ../util/utils.sh

NAMESPACE=external-secrets
NAME=external-secrets

helm repo add $NAME https://charts.external-secrets.io

helm_install $NAME external-secrets/external-secrets $NAMESPACE

check_all_pods_are_ready $NAMESPACE

kubectl apply -f vault-secret-store.yaml

if kubectl get ss -n $NAMESPACE vault-secret-store -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
    echo "secret store ready" 
else
    kubectl describe ss -n $NAMESPACE vault-secret-store
fi

