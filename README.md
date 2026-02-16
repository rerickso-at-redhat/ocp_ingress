# Demo Quickstart
1. run `aws configure --profile sandboxXYZ`, or create `~/.aws/config` and `~/.aws/credentials` files (or your preferred path with related export statements)
```
$ aws configure --profile sandboxXYZ
AWS Access Key ID [None]: Paste AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: Paste AWS_SECRET_ACCESS_KEY
Default region name [None]: ANY
Default output format [None]: ANY
```
2. `cd demo/aws`
3. `AWS_PROFILE=sandboxXYZ ansible-playbook demo.yml`

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
