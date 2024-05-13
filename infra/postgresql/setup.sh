#!/bin/sh

NAMESPACE="postgresql"

source ../util/utils.sh

createNamespace $NAMESPACE

k_apply postgresql.yaml

check_all_pods_are_ready $NAMESPACE