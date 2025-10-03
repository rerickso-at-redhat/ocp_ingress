APP=hello_app

oc delete deployments.apps $APP
oc delete services $APP
oc delete buildconfigs.build.openshift.io $APP
