#!/bin/bash

NAMESPACE=$1

# Get the list of pods in the terminating state
TERMINATING_PODS=$(kubectl get pods -n $NAMESPACE | grep Terminating | awk '{print $1}')

# Loop through each terminating pod and force delete it
for POD in $TERMINATING_PODS; do
    kubectl delete pod $POD -n $NAMESPACE --grace-period=0 --force
done

