#!/bin/bash

# Get the list of PVs in "Released" status
RELEASED_PVS=$(kubectl get pv | grep Released | awk '{print $1}')

# Check if there are any PVs in "Released" status
if [ -z "$RELEASED_PVS" ]; then
    echo "No PVs in 'Released' status found."
    exit 0
fi

# Loop through each PV
for pv in $RELEASED_PVS; do
    # Check if PV is bound to any PVC
    PVC=$(kubectl get pv $pv -o jsonpath='{.spec.claimRef.name}')
    if [ ! -z "$PVC" ]; then
        echo "PV $pv is still bound to PVC $PVC. Aborting deletion."
        continue
    fi

    # Check if PV is being used by any pods
    PODS=$(kubectl get pods --all-namespaces -o wide --field-selector spec.volumes.persistentVolumeClaim.claimName=$PVC | grep -v 'NAME' | wc -l)
    if [ $PODS -gt 0 ]; then
        echo "PV $pv is still being used by $PODS pods. Aborting deletion."
        continue
    fi

    # If PV is not bound to any PVC and not being used by any pods, delete it
    echo kubectl delete pv $pv
    echo "PV $pv has been deleted."
done

