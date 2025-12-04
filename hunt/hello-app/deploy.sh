#!/bin/bash

APP_NAME=$1

oc project $APP_NAME

oc new-app \
	https://github.com/rerickso-at-redhat/ocp_ingress.git#e2e \
	--strategy=docker \
	--context-dir=hunt/hello-app \
	--name=$APP_NAME

oc start-build --from-build=$APP_NAME-1 --build-arg app_name=$APP_NAME
