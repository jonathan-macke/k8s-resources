#!/bin/sh

minikube config set kubernetes-version v1.27.13
minikube start --alsologtostderr --v=2 --insecure-registry "gcr.io"
minikube addons enable registry