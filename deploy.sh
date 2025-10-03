#!/bin/bash

oc apply -f projects.yml

cd hello-app && ./deploy.sh
cd ..

git clone --depth 1 --single-branch --branch release-4.18 https://github.com/openshift/metallb-operator.git
oc apply -f metallb-operator/bin/metallb-operator.yaml

