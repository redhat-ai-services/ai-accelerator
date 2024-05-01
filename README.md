## Install GITOPS RHOAI and operators:
`oc login` into cluster

Run `./bootstrap.sh` to install GitOps, RHOAI, and other operators.
(May need to run bootstrap.sh again if installing components are slow)

After the script applies GitOps operator, it will prompt to choose the RHOAI folder to install the RHOAI operator and it's components. After it applies, you can go into GitOps and check the status of them. Sometimes, it needs to manually sync to get it going.
