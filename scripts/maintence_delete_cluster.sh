#!/bin/sh

main(){
    base_dir="bootstrap/overlays"

    echo
    PS3="Please enter a number to select a cluster to delete: "

    select bootstrap_dir in $(basename -a $base_dir/*/); 
    do
        test -n "$base_dir/$bootstrap_dir" && break;
        echo ">>> Invalid Selection";
    done

    echo
    echo "Selected: ${bootstrap_dir}"
    echo

    echo "You entered: $bootstrap_dir"
    read -rp "Are you sure you want to delete the folder(s) named '$bootstrap_dir'? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then

        delete_cluster_folder ${bootstrap_dir}

    else
        echo "Aborted. No folders were deleted."
        exit
    fi

}

delete_cluster_folder() {
    local REFERENCE_CLUSTER_NAME="$1"

    if [[ -z "$REFERENCE_CLUSTER_NAME" ]]; then
        echo "No cluster name entered. Exiting."
        return 1
    fi

    echo "Searching for and deleting folders named '$REFERENCE_CLUSTER_NAME'"

    # Find and delete matching directories
    find . -type d -name "$REFERENCE_CLUSTER_NAME" -print -exec rm -rf {} +

}

main
