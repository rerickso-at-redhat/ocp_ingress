APP=$(cat APP_NAME)

oc project hello-app

oc delete deployments.apps $APP
oc delete services $APP
oc delete buildconfigs.build.openshift.io $APP
