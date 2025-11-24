# AWS Environment Setup
1. cd demo/aws
2. ansible-playbook bootstrap_aws.yml
3. ansible-playbook deploy_bgplyml

# OpenShift Cluster Setup
1. cd ocp
2. Validate generated alpha.install-config.yaml file, edit if needed
3. Validate generated beta.install-config.yaml file, edit if needed
4. rm -rf alpha; mkdir alpha; cp alpha.install-config.yaml alpha/install-config.yaml
5. rm -rf beta; mkdir beta; cp beta.install-config.yaml beta/install-config.yaml
6. /path/to/openshift-install --dir alpha create cluster
7. /path/to/openshift-install --dir beta create cluster

# H.U.N.T. Setup
1. cd ../../hunt
2. vim deploy.sh
3. ./deploy.sh 
