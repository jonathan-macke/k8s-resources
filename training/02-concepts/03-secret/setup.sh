#!/bin/sh
NAMESPACE="concept-secret"
SECRET_ENGINE="test"
SECRET=$NAMESPACE


KEYSTORE_BASE64=$(base64 -i keystore.jks)

kubectl exec -t vault-0 -n vault -- vault kv put -mount=$SECRET_ENGINE $SECRET KEYSTORE_PWD=keystore KEYSTORE=$KEYSTORE_BASE64

kubectl create namespace $NAMESPACE

cd app
docker build -t app-keystore-secret .

# make the image available for downloading to k8s
minikube image load app-keystore-secret

cd ..

kubectl apply -f k8s/secret-store.yaml

if kubectl get ss -n $NAMESPACE app-secret-store -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
    echo "secret store ready" 
else
    kubectl describe ss -n $NAMESPACE app-secret-store
fi

kubectl apply -f k8s/deployment.yaml

kubens $NAMESPACE