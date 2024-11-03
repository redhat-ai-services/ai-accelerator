source "$(dirname "$0")/functions.sh"

# Reset Git Values
echo "Resetting Git Values"
patch_file "components/argocd/apps/base/cluster-config-app-of-apps.yaml" "main" ".spec.source.targetRevision"
patch_file "components/argocd/apps/base/cluster-config-app-of-apps.yaml" "https://github.com/redhat-ai-services/ai-accelerator.git" ".spec.source.repoURL"

echo -e "\e[32mValues reset locally. Please commit and push changes to the repository.\e[0m"