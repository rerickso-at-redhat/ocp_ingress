#!/bin/bash

#CLUSTERA="https://api.cluster-275lg.dynamic.redhatworkshops.io:6443"
CLUSTERA="api.cluster-p29md.dynamic.redhatworkshops.io:6443"
CLUSTERB="api.cluster-xm972.dynamic.redhatworkshops.io:6443"
CLUSTERA_CONTEXT="default/$(echo $CLUSTERA | sed s/\\./-/g)/admin" # Highly assumptive - demo purposes only
CLUSTERB_CONTEXT="default/$(echo $CLUSTERB | sed s/\\./-/g)/admin" # Highly assumptive - demo purposes only


set -ex

echo "Logging into Cluster A"
oc login --web --server=$CLUSTERA

echo "Logging into Cluster B"
oc login --web --server=$CLUSTERB

# Cluster A

echo "Using Cluster A"
oc config use-context $CLUSTERA_CONTEXT 

## Namespaces
oc apply -f namespaces.yml

## App 1
cd hello-app
# Allow the app deployment to fail as it may already be deployed and that script is not *currently* idempotent
set +e
./deploy.sh app1
set -e
cd ..

## Infrastructure CRDs
cd clustera
### MetalLB (https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator)
echo "NOTE: IP failover *MUST* be disabled before installing the MetalLB Operator..."
echo "      (Operator Install)    https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator#metallb-operator-install"
echo "      (IP failover removal) https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/configuring_network_settings/index#nw-ipfailover-remove_configuring-ipfailover"
oc apply -f 10-metallb-operator.yml
# TODO: The wait happens so fast the operator isnt even initializing yet so --all just includes preexisting ones. Additionally, wasnt able to initially find a way to get just the single operator as the name is dynamic. Needs work.
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
echo "NOTE: The MetalLB Operator *MUST* be installed to proceed..."
#### The MetalLB namespace *MUST* have the cluster-monitoring label for BGP/BFD metrics to appear in Prometheus...
oc label ns metallb-system "openshift.io/cluster-monitoring=true"
oc apply -f 12-metallb-metallb.yml
oc apply -f 14-metallb-ipaddresspool.yml
oc apply -f 16-metallb-bgppeer.yml
oc apply -f 18-metallb-bgpadvertisement.yml
### Gateway API (https://gateway-api.sigs.k8s.io/)
echo "NOTE: The cluster *MUST* have \"GatewayClass\" available (GA in OCP 4.19+) to proceed..."
oc apply -f 30-gateway-gatewayclass.yml 
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
oc apply -f 32-gateway-gateway.yml
oc apply -f 34-gateway-httproute-app1.yml
oc apply -f 36-gateway-httproute-app2.yml
### Red Hat Service Interconnect (https://docs.redhat.com/en/documentation/red_hat_service_interconnect/2.1)
# TODO: the latest rhsi seems to need the latest service mesh so it doesnt install automatically and instead creates an install plan
# Probably need to downgrade skupper or manually install service mesh before skupper (vs automatic with GatewayClass)
# Review the manual install plan for operators servicemeshoperator3.v3.1.2, skupper-operator.v2.1.1-rh-3. Once approved, the following resources will be created in order to satisfy the requirements for the components specified in the plan. Click the resource name to view the resource in detail.
oc apply -f 50-skupper-operator.yml
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
echo "NOTE: The Red Hat Service Interconnect Operator *MUST* be installed to proceed..."
oc apply -f 52-skupper-app1.yml
oc apply -f 54-skupper-app2.yml
cd ..


# Cluster B

oc config use-context $CLUSTERB_CONTEXT

## Namespaces
oc apply -f namespaces.yml

## App 2
cd hello-app
# Allow the app deployment to fail as it may already be deployed and that script is not *currently* idempotent
set +e
./deploy.sh app2
set -e
cd ..

## Infastructure CRDs
cd clusterb
### MetalLB (https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator)
echo "NOTE: IP failover *MUST* be disabled before installing the MetalLB Operator..."
echo "      (Operator Install)    https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator#metallb-operator-install"
echo "      (IP failover removal) https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/configuring_network_settings/index#nw-ipfailover-remove_configuring-ipfailover"
oc apply -f 10-metallb-operator.yml
# TODO: The wait happens so fast the operator isnt even initializing yet so --all just includes preexisting ones. Additionally, wasnt able to initially find a way to get just the single operator as the name is dynamic. Needs work.
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
echo "NOTE: The MetalLB Operator *MUST* be installed to proceed..."
#### The MetalLB namespace *MUST* have the cluster-monitoring label for BGP/BFD metrics to appear in Prometheus...
oc label ns metallb-system "openshift.io/cluster-monitoring=true"
oc apply -f 12-metallb-metallb.yml
oc apply -f 14-metallb-ipaddresspool.yml
oc apply -f 16-metallb-bgppeer.yml
oc apply -f 18-metallb-bgpadvertisement.yml
### Gateway API (https://gateway-api.sigs.k8s.io/)
echo "NOTE: The cluster *MUST* have \"GatewayClass\" available (GA in OCP 4.19+) to proceed..."
oc apply -f 30-gateway-gatewayclass.yml
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
oc apply -f 32-gateway-gateway.yml
oc apply -f 34-gateway-httproute-app1.yml
oc apply -f 36-gateway-httproute-app2.yml
### Red Hat Service Interconnect (https://docs.redhat.com/en/documentation/red_hat_service_interconnect/2.1)
# TODO: the latest rhsi seems to need the latest service mesh so it doesnt install automatically and instead creates an install plan
# Probably need to downgrade skupper or manually install service mesh before skupper (vs automatic with GatewayClass)
# Review the manual install plan for operators servicemeshoperator3.v3.1.2, skupper-operator.v2.1.1-rh-3. Once approved, the following resources will be created in order to satisfy the requirements for the components specified in the plan. Click the resource name to view the resource in detail.
oc apply -f 50-skupper-operator.yml
sleep 5
oc wait clusterserviceversions --all --for=jsonpath='{.status.phase}=Succeeded'
echo "NOTE: The Red Hat Service Interconnect Operator *MUST* be installed to proceed..."
oc apply -f 52-skupper-app1.yml
oc apply -f 54-skupper-app2.yml
cd ..


# Red Hat Service Interconnect (Skupper API & CLI Mixture)

## Cluster A
oc config use-context $CLUSTERA_CONTEXT
skupper --namespace app1 token issue app1-token.yml

## Cluster B
oc config use-context $CLUSTERB_CONTEXT
skupper --namespace app2 token issue app2-token.yml
skupper --namesapce app1 token redeem app1-token.yml

## Cluster A
oc config use-context $CLUSTERA_CONTEXT
skupper --namespace app2 token redeem app2-token.yml


# Red Hat Service Interconnect (Skupper CLI Only)

### Cluster A
#oc login --server=$CLUSTERA || oc login --web --server=$CLUSTERA
#
#### App 1 (incoming links from remotes sites to app1)
#skupper --namespace app1 site create --enable-link-access app1
#skupper --namespace app1 connector create app1 8080 --workload deployment/app1
#skupper --namespace app1 token issue app1-token.yml
#
#### App 2 (outgoing links to app2)
#skupper --namespace app2 site create app2
#
### Cluster B
#oc login --server=$CLUSTERB || oc login --web --server=$CLUSTERB
#
#### App 1 (outgoing links to app1)
#skupper --namespace app1 site create app1
#skupper --namespace app1 token redeem app1-token.yml
#skupper --namespace app1 listener create app1 8080
#
#### App 2 (incoming links from remote sites to app2)
#skupper --namespace app2 site create --enable-link-access app2
#skupper --namespace app2 connector create app2 8080 --workload deployment/app2
#skupper --namespace app2 token issue app2-token.yml
#
### Cluster A
#oc login --server=$CLUSTERA || oc login --web --server=$CLUSTERA
#
#### App 2 (outgoing links to app2)
#skupper --namespace app2 token redeem app2-token.yml
#skupper --namespace app2 listener create app2 8080

