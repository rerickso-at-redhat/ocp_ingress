#!/bin/bash

# Works with a single ApplicationSet named "ingressmesh"
alpha patch --type merge -n openshift-gitops -p '{"spec":{"template": {"spec": {"syncPolicy":{"automated":{"selfHeal":false,"prune":true}}}}}}' applicationset/ingressmesh;
beta patch --type merge -n openshift-gitops -p '{"spec":{"template": {"spec": {"syncPolicy":{"automated":{"selfHeal":false,"prune":true}}}}}}' applicationset/ingressmesh;

# Works with individual Applications
#for app in rhsi metallb gatewayapi app1 app2 app3; do
#	alpha patch --type merge -n openshift-gitops -p '{"spec":{"syncPolicy":{"automated":{"selfHeal":false,"prune":true}}}}' app/$app;
#	beta patch --type merge -n openshift-gitops -p '{"spec":{"syncPolicy":{"automated":{"selfHeal":false,"prune":true}}}}' app/$app;
#done
