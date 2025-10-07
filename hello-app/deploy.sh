#!/bin/bash

APP_NAME=$1

oc project $APP_NAME

oc new-app \
	https://github.com/rerickso-at-redhat/ocp_ingress.git#e2e \
	--strategy=docker \
	--context-dir=hello-app \
	--name=$APP_NAME
