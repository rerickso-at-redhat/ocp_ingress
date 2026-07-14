# About
This directory stores OpenShift configurations and secrets generated via `openshift-install` during the install_openshift.yml playbook.

If you are mantaining multiple different environments, it is recommended that you create a `current` symlink to point to your latest install.

This enables you to then configure an aliases such as:
```
alias alpha="oc --kubeconfig=$PWD/demo/aws/ocp/current/alpha/auth/kubeconfig"
alias beta="oc --kubeconfig=$PWD/demo/aws/ocp/current/beta/auth/kubeconfig"
```
