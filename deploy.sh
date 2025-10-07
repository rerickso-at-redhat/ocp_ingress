#!/bin/bash

CLUSTERA="https://api.cluster-275lg.dynamic.redhatworkshops.io:6443"
CLUSTERB="https://api.cluster-xm972.dynamic.redhatworkshops.io:6443"

set -e


## CLUSTER A / APP1 ##

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
cd ..


## CLUSTER B / APP2 ##

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
cd ..

