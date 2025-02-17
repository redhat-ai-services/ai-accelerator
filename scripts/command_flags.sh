# Help function
function show_help {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --ocp_version=4.11    Target Openshift Version"
  echo "  --BOOTSTRAP_DIR=<bootstrap_directory>    Base folder inside of bootstrap/overlays (Optional, pick during script execution if not set)"
  echo "  --timeout=45          Timeout in seconds for waiting for each resource to be ready"
  echo "  -f                    If set, will update the \`patch-application-repo-revision\` folder inside of your overlay with the current git information and push a checkin"
  echo "  --reset-git           Locally resets changes made by the bootstrap script. Please run and checkin the changes before creating a PR"
  echo "  --help                Show this help message"
}

for arg in "$@"
do
  case $arg in
    --cluster=*)
      export CLUSTER_NAME="${arg#*=}"
      shift
    ;;
    --ocp_version=*)
      export OCP_VERSION="${arg#*=}"
      echo "Using OCP Bianaires Version: ${OCP_VERSION}"
      shift
    ;;
    --bootstrap_dir=*)
      export BOOTSTRAP_DIR="${arg#*=}"
      echo "Using Bootstrap Directory: ${BOOTSTRAP_DIR}"
      shift
    ;;
    -f)
      export FORCE=true
      echo "Force set, using current git branch"
      shift
    ;;
    --reset-git)
      source "$(dirname "$0")/reset_git.sh"
      exit 0
    ;;
    --help)
      show_help
      exit 0
    ;;

  esac
done

