#!/bin/bash

# Check the current project
CURRENT_PROJECT=$(oc project --short=false)
if [ $? -ne 0 ]; then
    echo "Failed to get the current project."
    exit 1
fi

echo "You are currently in the project: $CURRENT_PROJECT"

# Ask the user if they want to continue
read -p "Would you like to continue and delete resources in the current project? (yes/no): " CONTINUE

if [ "$CONTINUE" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

oc delete argocd --all -n openshift-gitops
if [ $? -ne 0 ]; then
    echo "Failed to delete argocd."
    exit 1
fi

oc delete pods --all -n openshift-gitops-operator
if [ $? -ne 0 ]; then
    echo "Failed to delete pods."
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Commands executed successfully."
else
    echo "Failed to execute commands on the remote server."
    exit 1
fi

echo "rerun ./bootstrap.sh "
