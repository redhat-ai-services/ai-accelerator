#!/bin/bash

# Check if the correct number of parameters is passed
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <ssh_key> <hostname_or_ip> [ssh_port]"
    exit 1
fi

SSH_KEY=$1
HOST=$2
SSH_PORT=${3:-22}

# Ask the user if the ssh key needs to be copied
read -p "Do you need to copy the SSH key to the host? (yes/no): " COPY_KEY

if [ "$COPY_KEY" = "yes" ]; then
    ssh-copy-id -o StrictHostKeyChecking=no -o PubkeyAuthentication=no -i "$SSH_KEY" -p "$SSH_PORT" "$HOST"
    if [ $? -ne 0 ]; then
        echo "Failed to copy SSH key."
        exit 1
    fi
fi

# Run the remote commands
ssh -i "$SSH_KEY" -p "$SSH_PORT" "$HOST" << EOF
    oc delete argocd --all -n openshift-gitops
    oc delete pods --all -n openshift-gitops-operator
EOF

# Check if the remote commands executed successfully
if [ $? -eq 0 ]; then
    echo "Commands executed successfully. \n rerun ./bootstrap.sh"
else
    echo "Failed to execute commands on the remote host."
    exit 1
fi
