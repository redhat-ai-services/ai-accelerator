#!/usr/bin/env bash

export HOME=/tmp/approver

echo "Approving operator install.  Waiting a few seconds to make sure the InstallPlan gets created first."
sleep "${SLEEP:-20}"

for subscription in $(oc get subscriptions.operators.coreos.com -o jsonpath='{.items[*].metadata.name}'); do
  echo "Processing subscription '${subscription}'"

  installplan=$(oc get subscriptions.operators.coreos.com --field-selector "metadata.name=${subscription}" -o jsonpath='{.items[0].status.installPlanRef.name}')

  echo "Check installplan approved status"
  oc get installplan "${installplan}" -o jsonpath="{.spec.approved}"

  if [ "$(oc get installplan "${installplan}" -o jsonpath="{.spec.approved}")" == "false" ]; then
    echo "Approving Subscription ${subscription} with install plan ${installplan}"
    oc patch installplan "${installplan}" --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
  else
    echo "Install Plan '${installplan}' already approved"
  fi
done
