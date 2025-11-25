#!/bin/bash

ALPHA="api.alpha.sandbox1866.opentlc.com:6443"
BETA="api.beta.sandbox1866.opentlc.com:6443"

# KUBEADMIN
ALPHA_CONTEXT="default/$(echo $ALPHA | sed s/\\./-/g)/kube:admin" # NOTE: Highly assumptive - demo purposes only
BETA_CONTEXT="default/$(echo $BETA | sed s/\\./-/g)/kube:admin" # NOTE: Highly assumptive - demo purposes only

# ADMIN
#ALPHA_CONTEXT="default/$(echo $ALPHA | sed s/\\./-/g)/admin" # NOTE: Highly assumptive - demo purposes only
#BETA_CONTEXT="default/$(echo $BETA | sed s/\\./-/g)/admin" # NOTE: Highly assumptive - demo purposes only

function main () {
	set -ex

	# Authentication # NOTE: Utilizing a very generic authentication pattern - feel free to manually swap this out with your needs or preferences
	echo "Logging into Alpha Cluster"
	oc login --web --server=$ALPHA
	oc project default

	echo "Logging into Beta Cluster"
	oc login --web --server=$BETA
	oc project default

	# Alpha Cluster
	echo "Using Alpha Cluster"
	oc config use-context $ALPHA_CONTEXT

	## Namespaces
	oc apply -f namespaces.yml

	## App 1
	deploy_app app1

	## Infrastructure Manifests
	cd alpha
	apply_manifests
	cd ..
	
	# Beta Cluster
	echo "Using Beta Cluster"
	oc config use-context $BETA_CONTEXT

	## Namespaces
	oc apply -f namespaces.yml

	## App 2
	deploy_app app2

	## Infrastucture Manifests
	cd beta
	apply_manifests
	cd ..


	# Red Hat Service Interconnect (Skupper API & CLI Mixture)

	## Alpha Cluster
	oc config use-context $ALPHA_CONTEXT
	skupper --namespace app1 token issue app1-token.yml

	## Beta Cluster
	oc config use-context $BETA_CONTEXT
	skupper --namespace app2 token issue app2-token.yml
	skupper --namespace app1 token redeem app1-token.yml

	## Alpha Cluster
	oc config use-context $ALPHA_CONTEXT
	skupper --namespace app2 token redeem app2-token.yml
}

function deploy_app () {
        cd hello-app
        # Allow the app deployment to fail as it may already be deployed and that script is not *currently* idempotent
        set +e
        ./deploy.sh $1
        set -e
        cd ..
}


function wait_for_operator () {
	OPERATOR_NAME=$1
        until [ $(oc -n openshift-operators get csv | grep $OPERATOR_NAME > /dev/null; echo $?) == 0 ]; do echo "Waiting for operator: $OPERATOR_NAME"; sleep 5; done
	oc wait --for jsonpath='{.status.phase}'=Succeeded --timeout=10m -n openshift-operators $(oc get csv -n openshift-operators -oname | grep $OPERATOR_NAME)

}


function wait_for_installplan () {
        until [ $(oc -n openshift-operators get installplan | grep false > /dev/null; echo $?) == 1 ]; do echo "Waiting for installplan ..."; sleep 5; done
}


function wait_for_site () {
	SITE=$1
	until [ $(oc -n $SITE get site/$SITE -o name) ]; do echo "Waiting for site/$SITE ..."; sleep 5; done
	oc -n $SITE wait --for jsonpath='{.status.status}'=Ready --timeout=10m site/$SITE
}


# NOTE: Demo purposes only as this blindly approves any pending installplans in the openshift-operators namespace
function approve_installplans () {
	for ip in $(oc -n openshift-operators get ip -o=jsonpath='{.items[?(@.spec.approved==false)].metadata.name}'); do
		oc -n openshift-operators patch installplan $ip --type merge -p '{"spec":{"approved":true}}';
	done
}


function apply_manifests () {
        # MetalLB (https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator)
        echo "NOTE: IP failover *MUST* be disabled before installing the MetalLB Operator..."
        echo "      (Operator Install)    https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/networking_operators/metallb-operator#metallb-operator-install"
        echo "      (IP failover removal) https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/configuring_network_settings/index#nw-ipfailover-remove_configuring-ipfailover"
        oc apply -f 10-metallb-operator.yml
	wait_for_operator metallb-operator
        echo "NOTE: The MetalLB Operator *MUST* be installed to proceed..."
        ## The MetalLB namespace *MUST* have the cluster-monitoring label for BGP/BFD metrics to appear in Prometheus...
        oc label ns metallb-system "openshift.io/cluster-monitoring=true"
        oc apply -f 12-metallb-metallb.yml
        oc apply -f 14-metallb-ipaddresspool.yml
        oc apply -f 16-metallb-bgppeer.yml
        oc apply -f 18-metallb-bgpadvertisement.yml

	# OpenShift Service Mesh / Gateway API (https://gateway-api.sigs.k8s.io/)
	echo "NOTE: The cluster *MUST* have \"GatewayClass\" available (GA in OCP 4.19+) to proceed..."
	
	if  oc get clusterversion | grep 4.19 || oc get clusterversion | grep 4.20 > /dev/null; then
        	## >=4.19 has the Gateway API CRDs and will automatically trigger a minimal OSSM operator install
        	echo "Clusterversion is >= 4.19 - no Gateway API CRDs required. Continuing ..."
		oc apply -f 30-gateway-gatewayclass.yml
		wait_for_operator servicemeshoperator
		approve_installplans
		wait_for_operator servicemeshoperator
		oc apply -f 32-gateway-gateway.yml
		oc apply -f 34-gateway-httproute-app1.yml
		oc apply -f 36-gateway-httproute-app2.yml

	elif oc get clusterversion | grep 4.18 > /dev/null; then
		## <4.19 requires Gateway API CRDs and a manual OSSM install
		echo "Clusterversion is < 4.19. Gateway API CRDs required. Installing ..."
		oc apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
		echo "INCOMPLETE FOR 4.18 - UNABLE TO CONTINUE"
		# oc apply -f 20-openshift-service-mesh-operator.yml
		# wait_for_operator servicemeshoperator
		# ... other steps ...
		oc apply -f 30-gateway-gatewayclass.yml
		oc apply -f 32-gateway-gateway.yml
                oc apply -f 34-gateway-httproute-app1.yml
                oc apply -f 36-gateway-httproute-app2.yml

	fi

	# Red Hat Service Interconnect (https://docs.redhat.com/en/documentation/red_hat_service_interconnect/2.1)
        oc apply -f 50-skupper-operator.yml
	wait_for_installplan
	approve_installplans
	wait_for_operator skupper-operator
        echo "NOTE: The Red Hat Service Interconnect Operator *MUST* be installed to proceed..."
        oc apply -f 52-skupper-app1.yml
	wait_for_site app1
        oc apply -f 54-skupper-app2.yml
	wait_for_site app2
}

main


# Alternative Red Hat Service Interconnect Configuration (Skupper CLI Only)

### Alpha Cluster
#oc login --server=$ALPHA || oc login --web --server=$ALPHA
#
#### App 1 (incoming links from remotes sites to app1)
#skupper --namespace app1 site create --enable-link-access app1
#skupper --namespace app1 connector create app1 8080 --workload deployment/app1
#skupper --namespace app1 token issue app1-token.yml
#
#### App 2 (outgoing links to app2)
#skupper --namespace app2 site create app2
#
### Beta Cluster
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
### Alpha Cluster
#oc login --server=$ALPHA || oc login --web --server=$ALPHA
#
#### App 2 (outgoing links to app2)
#skupper --namespace app2 token redeem app2-token.yml
#skupper --namespace app2 listener create app2 8080

