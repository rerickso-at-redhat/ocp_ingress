#!/bin/bash
# establish a site from clustera ns/app1 to clusterb ns/app1
# on clustera in ns/app1
oc project app1
skupper site create [sitename] --enable-link-access
# create a token so cluster b can join
skupper token issue clusterb-token.yaml

###
# now go to clusterb and redeem the token
# oc project app1
# skupper token redeem clusterb-token.yaml

# create a connector for app1 (allowing trafic to come from clusterb)
skupper connector create app1 8080 --workload deployment/app1



# create a listener for app2 (this allows clustera to send traffic for app1 here)
oc project app2
skupper listener create app2 8080

