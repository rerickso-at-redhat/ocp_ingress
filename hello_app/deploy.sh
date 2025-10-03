#!/bin/bash
oc new-app \
	https://github.com/rerickso-at-redhat/ocp_ingress.git#e2e \
	--strategy=docker \
	--context-dir=hello_app \
	--name=hello_app
