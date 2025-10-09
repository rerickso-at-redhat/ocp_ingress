# Installation

## Update deploy.sh

Update the deploy.sh file with your clustera/clusterv API URLs

```cat deploy.sh 
#!/bin/bash

CLUSTERA="api.cluster-p29md.dynamic.redhatworkshops.io:6443"
CLUSTERB="api.cluster-xm972.dynamic.redhatworkshops.io:6443"

...

```

## Ensure that you have the following prerequsites installed

### Binaries
`oc`
- Available from the OpenShift GUI (? -> Command Line Tools)

`skupper`
- Available from access.redhat.com/downloads - select A-Z then Red Hat Service Interconnect
- Direct Link: https://access.redhat.com/jbossnetwork/restricted/listSoftware.html?downloadType=distributions&product=redhat.service.interconnect

## Run the deploy.sh script
./deploy.sh

# Documentation Links

## Operators

### MetalLB
https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator

### Gateway API
The Gateway API is built into OCP 4.19+
Creating a GatewayClass CRD will silently bootstrap the Gateway API to allow GatewayClass/Gateway/HTTPRoute objects to be created.

https://gateway-api.sigs.k8s.io/

### Red Hat Service Interconnect
https://docs.redhat.com/en/documentation/red_hat_service_interconnect/2.1/html/installation/installing-operator

## Application Development
The included hello-app is a very simple webserver that allows for basic connectivity testing at various levels (bgp, rhsi, etc).

https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/building_applications/building-applications-overview

