#!/bin/sh

createNamespace() {
    if kubectl get namespace $1 &> /dev/null; then
        echo "Namespace $1 already exists."
    else
        kubectl create namespace $1
        echo "Namespace $1 created successfully."
    fi
}

helm_install() {
    NAME=$1
    CHART=$2
    NAMESPACE=$3

    if helm list -n $NAMESPACE -o json | jq ".[] | select(.name == \"$NAME\").status" | grep -q "deployed"; then
        echo "$NAME chart already deployed"
    else 
        helm install $NAME $CHART -n $NAMESPACE --create-namespace
    fi
}


is_helm_deployed() {
    if helm status vault -n $1 -o json | jq '.info.status' | grep -q "deployed"; then
        return 0 
    else
        return 1 
    fi
}

check_helm_deployed() {
    while ! (is_helm_deployed $1); do
        echo "Waiting for helm chart to be deployed..."
        sleep 5
    done
}


k_apply() {
    kubectl apply -f $1
}


is_pod_ready() {
    if kubectl get pod -n $1 $2 &> /dev/null; then
        if kubectl get pod -n $1 $2 -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; then
            return 0 # Pod is ready
        else
            return 1 # Pod is not ready yet
        fi
    else
        return 2 # Pod not found
    fi
}


check_all_pods_are_ready() {
    pod_names=$(kubectl get pods -n "$1" -o=jsonpath='{.items[*].metadata.name}')

    # Convert the space-separated string of pod names into an array
    read -ra pod_array <<<"$pod_names"

    for pod_name in "${pod_array[@]}"; do
        echo "Waiting for pod $pod_name to be ready..."
        until kubectl wait --for=condition=Ready pod/"$pod_name" -n "$1" --timeout=300s; do
            echo "Pod $pod_name is not ready yet, waiting..."
            sleep 10
        done
        echo "Pod $pod_name is ready."
    done
}


check_pod_ready() {
    while ! (is_pod_ready $1 $2); do
        echo "Waiting for pod to be ready..."
        sleep 5
    done
    echo "Pod is now ready"
}
