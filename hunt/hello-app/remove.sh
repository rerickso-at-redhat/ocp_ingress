APP_NAME=$1

oc project $APP_NAME

oc delete deployments.apps $APP_NAME
oc delete services $APP_NAME
oc delete buildconfigs.build.openshift.io $APP_NAME
