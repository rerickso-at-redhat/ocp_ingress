#!/bin/bash
# establish a site from clustern ns/app2 to clustera ns/app2
# on clusterb in ns/app2
oc project app2
skupper site create [sitename] --enable-link-access
# create a token so cluster a can join
skupper token issue clustera-token.yaml

# now go redeem the token on clustera
# oc project app2
# skupper token redeem clustera-token.yaml

# create a connector for app2 (allowing trafic to come from clustera)
skupper connector create app2 8080 --workload deployment/app2

# create a listener for app1 (this allows clusterb to send traffic for app1 to clustera)
oc project app1
skupper listener create app1 8080

