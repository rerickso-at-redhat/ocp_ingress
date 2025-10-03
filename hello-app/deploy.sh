#!/bin/bash

oc project hello-app

oc new-app \
	https://github.com/rerickso-at-redhat/ocp_ingress.git#e2e \
	--strategy=docker \
	--context-dir=hello-app \
	--name=$(cat APP_NAME)
