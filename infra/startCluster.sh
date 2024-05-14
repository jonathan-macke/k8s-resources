#!/bin/sh

minikube config set kubernetes-version v1.27.13
minikube start --nodes 3 --insecure-registry "gcr.io" -p prod

#minikube start --insecure-registry "gcr.io" -p prod