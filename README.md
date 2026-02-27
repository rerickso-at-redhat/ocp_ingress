# Demo Quickstart
1. Run `aws configure --profile sandboxXYZ`, or create `~/.aws/config` and `~/.aws/credentials` files (or your preferred path with related export statements)

```
$ aws configure --profile sandboxXYZ
AWS Access Key ID [None]: Paste AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: Paste AWS_SECRET_ACCESS_KEY
Default region name [None]: ANY
Default output format [None]: ANY
```

2. Ensure `openshift-install` is available in your $PATH (via a bin/, alias, etc) and on the correct version you'd like to deploy

https://console.redhat.com/openshift/install/metal/agent-based

```
$ which openshift-install
~/.local/bin/openshift-install
```

```
$ alias openshift-install="/path/to/openshift-install"
$ which openshift-install
alias openshift-install='/path/to/openshift-install'
```

3. Ensure `oc` is available in your $PATH (via a bin/, alias, etc) and on the correct version

https://console.redhat.com/openshift/install/metal/agent-based

```
$ which oc
~/.local/bin/oc
```

```
$ alias oc="/path/to/oc"
$ which oc
alias oc='/path/to/oc'
```

4. Ensure `ansible` is installed

Ansible can be installed in your local system or if you wanted to add the openshift-install and oc binaries to an ansible execution environment then you could do that as well (not described in this readme).

```
dnf install ansible
```

```
apt install ansible
```

5. Ensure `boto3 >= 1.34.0` and `botocore >= 1.34.0` are available in your python environment (ansible AWS module requirement)

These can be installed in your local system or if you wanted to add the openshift-install and oc binaries to an ansible execution environment then you could do that as well (not described in this readme).

```
$ pip3 freeze | grep boto
boto3==1.42.47
botocore==1.42.47
```

```
pip3 install boto3 botocore
```

6. `cd demo/aws`

7. `AWS_PROFILE=sandboxXYZ ansible-playbook demo.yml`

# H.U.N.T. Setup

In order to update the "H.U.N.T." portion of the demo on an existing cluster, you *may need* to re-run some number of playbooks up to and including the `deploy_argo_apps.yml` playbook.

This *will* only be required when you have modified one of the infrastructure vars/playbooks, or one of the argo application manifests located in `demo/aws/ocp/sandbox*`.

This *will not* be required when modifying the helm application charts located in `hunt/charts` as those will be seen by the argo applications once the source is pushed to the repo.

```
$ ls demo/aws/ocp/sandbox*
demo/aws/ocp/sandboxXYZ.opentlc.com:
alpha  alpha.install-config.yaml  beta  beta.install-config.yaml  generated_facts.yml
```

```
$ tree demo/aws/ocp/sandboxXYZ.opentlc.com/
demo/aws/ocp/sandboxXYZ.opentlc.com/
├── alpha
│   ├── argo
│   │   ├── app.app1.yml
│   │   ├── app.app2.yml
│   │   ├── app.gatewayapi.yml
│   │   ├── app.metallb.yml
│   │   └── app.rhsi.yml
│   ├── auth
│   │   ├── kubeadmin-password
│   │   └── kubeconfig
│   ├── install.log.txt
│   ├── metadata.json
│   ├── terraform.platform.auto.tfvars.json
│   ├── terraform.tfvars.json
│   └── tls
│       ├── journal-gatewayd.crt
│       └── journal-gatewayd.key
├── alpha.install-config.yaml
├── beta
│   ├── argo
│   │   ├── app.app1.yml
│   │   ├── app.app2.yml
│   │   ├── app.gatewayapi.yml
│   │   ├── app.metallb.yml
│   │   └── app.rhsi.yml
│   ├── auth
│   │   ├── kubeadmin-password
│   │   └── kubeconfig
│   ├── install.log.txt
│   ├── metadata.json
│   ├── terraform.platform.auto.tfvars.json
│   ├── terraform.tfvars.json
│   └── tls
│       ├── journal-gatewayd.crt
│       └── journal-gatewayd.key
├── beta.install-config.yaml
└── generated_facts.yml
```

It should be safe to re-run the whole `demo.yml` playbook but if you would like to specifically run just the argo application deployment and following playbooks you can use the following:

```
AWS_PROFILE=sandboxXYZ ansible-playbook demo.yml --tags deploy_argo_apps,approve_install_plans,deploy_rhsi_tokens
```
