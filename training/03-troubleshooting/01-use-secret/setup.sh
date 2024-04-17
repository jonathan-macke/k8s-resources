#!/bin/sh
NAMESPACE="01-use-secret"
SECRET_ENGINE="test"
SECRET=$NAMESPACE


kubectl exec -t vault-0 -n vault -- vault kv put -mount=$SECRET_ENGINE $SECRET DB_PWD=SecurePassword DB_USER=ps_user DB_URL=jdbc:postgresql://db.postgresql:5432/ps_db

kubectl create namespace $NAMESPACE

cd app
docker build -t use_secret .
minikube image load use_secret

cd ..

kubectl apply -f k8s/secret-store.yaml

if kubectl get ss -n $NAMESPACE app-secret-store -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
    echo "secret store ready" 
else
    kubectl describe ss -n $NAMESPACE app-secret-store
fi

kubectl apply -f k8s/deployment.yaml