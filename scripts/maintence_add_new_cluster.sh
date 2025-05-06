#!/bin/sh

main(){
    base_dir="bootstrap/overlays"

    echo
    PS3="Please enter a number to select a cluster to use as a reference: "

    select bootstrap_dir in $(basename -a $base_dir/*/); 
    do
        test -n "$base_dir/$bootstrap_dir" && break;
        echo ">>> Invalid Selection";
    done

    echo
    echo "Selected: ${bootstrap_dir}"
    echo

    read -rp "Enter the new cluster name: " new_cluster

    create_new_cluster ${bootstrap_dir} ${new_cluster}

}

create_new_cluster() {
    local REFERENCE_CLUSTER_NAME="$1"
    local NEW_CLUSTER_NAME="$2"

    # Validate parameters
    if [[ -z "$REFERENCE_CLUSTER_NAME" || -z "$NEW_CLUSTER_NAME" ]]; then
        echo "Usage: create_new_cluster <REFERENCE_CLUSTER_NAME> <NEW_CLUSTER_NAME>"
        return 1
    fi

    echo "Searching for folders named '$REFERENCE_CLUSTER_NAME'..."

    # Find matching directories
    find . -type d -name "$REFERENCE_CLUSTER_NAME" | while read -r ref_dir; do
        local new_dir="${ref_dir%/$REFERENCE_CLUSTER_NAME}/$NEW_CLUSTER_NAME"

        echo "Copying '$ref_dir' to '$new_dir'..."
        cp -r "$ref_dir" "$new_dir"

        echo "Replacing references inside '$new_dir'..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            find "$new_dir" -type f -exec grep -Iq . {} \; -exec sed -i '' "s|$REFERENCE_CLUSTER_NAME|$NEW_CLUSTER_NAME|g" {} +
        else
            find "$new_dir" -type f -exec grep -Iq . {} \; -exec sed -i "s|$REFERENCE_CLUSTER_NAME|$NEW_CLUSTER_NAME|g" {} +
        fi
    done

    echo "Done."
}

main
