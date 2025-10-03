#!/bin/bash
oc apply -f project.yml

oc project $(cat project.yml | grep name | sed -r 's/\s+name://')

oc new-app \
	https://github.com/rerickso-at-redhat/ocp_ingress.git#e2e \
	--strategy=docker \
	--context-dir=hello_app \
	--name=$(cat APP_NAME)
