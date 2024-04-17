#!/bin/sh

NAMESPACE="postgresql"

kubectl create namespace $NAMESPACE

kubectl apply -f postgresql.yaml