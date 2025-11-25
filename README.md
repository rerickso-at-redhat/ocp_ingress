# AWS Environment Setup
1. run `aws configure`, or create `~/.aws/config` and `~/.aws/credentials` files (or your preferred path with related export statements)
2. `cd demo/aws`
3. `ansible-playbook bootstrap_aws.yml`
4. `ansible-playbook deploy_bgp.yml`

# OpenShift Cluster Setup
1. `cd ocp`
2. Validate generated alpha.install-config.yaml file, edit if needed
3. Validate generated beta.install-config.yaml file, edit if needed
4. `rm -rf alpha; mkdir alpha; cp alpha.install-config.yaml alpha/install-config.yaml`
5. `rm -rf beta; mkdir beta; cp beta.install-config.yaml beta/install-config.yaml`
6. `/path/to/openshift-install --dir alpha create cluster`
7. `/path/to/openshift-install --dir beta create cluster`

# H.U.N.T. Setup
1. `cd ../../hunt`
2. `vim deploy.sh` - Edit the api paths and chose the kubeadmin or admin contexts (uncomment accordingly)
3. `./deploy.sh` 
