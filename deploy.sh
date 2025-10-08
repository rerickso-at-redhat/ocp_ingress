#!/bin/bash

CLUSTERA="https://api.cluster-275lg.dynamic.redhatworkshops.io:6443"
CLUSTERB="https://api.cluster-xm972.dynamic.redhatworkshops.io:6443"

set -e

# CLUSTER A / APP 1

oc login --web --server=$CLUSTERA || (echo "Unable to log into clustera: $CLUSTERA" && exit 1)

oc apply -f projects.yml

cd hello-app
# Allow the app deployment to fail as it may already be deployed and that script is not *currently* idempotent
set +e
./deploy.sh app1
set -e
cd ..

cd clustera
echo "NOTE: The MetalLB Operator *MUST* be installed to proceed..."
oc apply -f 01_metal-addresspool.yaml
oc apply -f 02_metal-bgppeer.yaml
oc apply -f 03_metal-bgpadvertisement.yaml
echo "NOTE: The cluster *MUST* have \"GatewayClass\" available (GA in OCP 4.19+) to proceed..."
oc apply -f 04_gateway-class.yaml
sleep 60
oc apply -f 05_shared-gateway.yaml
oc apply -f 06_app1-gateway-http-route.yaml
oc apply -f 07_app2-gateway-http-route.yaml
#echo "NOTE: The Red Hat Service Interconnect Operator *MUST* be installed to proceed..."
#./08_skupper_config.sh
cd ..


# Cluster B / APP 2

oc login --web --server=$CLUSTERB || (echo "Unable to log into clusterb: $CLUSTERB" && exit 1)

oc apply -f projects.yml

cd hello-app
# Allow the app deployment to fail as it may already be deployed and that script is not *currently* idempotent
set +e
./deploy.sh app2
set -e
cd ..

cd clusterb
echo "NOTE: The MetalLB Operator *MUST* be installed to proceed..."
oc apply -f 01_metal-addresspool.yaml
oc apply -f 02_metal-bgppeer.yaml
oc apply -f 03_metal-bgpadvertisement.yaml
echo "NOTE: The cluster *MUST* have \"GatewayClass\" available (GA in OCP 4.19+) to proceed..."
oc apply -f 04_gateway-class.yaml
sleep 60
oc apply -f 05_shared-gateway.yaml
oc apply -f 06_app1-gateway-http-route.yaml
oc apply -f 07_app2-gateway-http-route.yaml
#echo "NOTE: The Red Hat Service Interconnect Operator *MUST* be installed to proceed..."
#./08_skupper_config.sh
cd ..


# Red Hat Service Interconnect (Skupper)

## Cluster A
oc login --server=$CLUSTERA || oc login --web --server=$CLUSTERA

### App 1
skupper --namespace app1 site create --enable-link-access app1
skupper --namespace app1 token issue app1-token.yml
skupper --namespace app1 connector create app1 8080 --workload deployment/app1

### App 2
skupper --namespace app2 site create --enable-link-access app2


## Cluster B
oc login --server=$CLUSTERB || oc login --web --server=$CLUSTERB

### App 1
skupper --namespace app1 site create --enable-link-access app1
skupper --namespace app1 token redeem app2-token.yml

### App 2
skupper --namespace app2 site create --enable-link-access app2
skupper --namespace app2 token issue app2-token.yml
skupper --namespace app2 connector create app2 8080 --workload deployment/app2


## Cluster A
oc login --server=$CLUSTERA || oc login --web --server=$CLUSTERA

### App 2
skupper --namespace app2 token redeem app2-token.yml

