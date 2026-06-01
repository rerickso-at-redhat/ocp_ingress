# Demo Prerequisites

There are many ways to install each prerequisite, from package managers to Ansible Execution Environments. Feel free to research/install/configure each as appropriate for your needs. By default, this installation will assume you are on an x86 CPU with a Fedora/RHEL OS and you are fine with system-level installs of all dependencies (dnf, pip3, etc).

## `ansible`

https://docs.ansible.com/projects/ansible/latest/installation_guide/index.html

```
dnf install -y ansible || apt install -y ansible
```

## Ansible Collections

The following Ansible collections are required:
    - amazon.aws
    - kubernetes.core

```
ansible-galaxy collection install amazon.aws kubernetes.core
```

## Ansible Python Dependencies

The following python packages are required in Ansible's python environment for the Ansible AWS and Kubernetes modules to function:
    - `boto3 >= 1.34.0`
    - `botocore >= 1.34.0`
    - `kubernetes >= 24.2.0`
    - `pyyaml >= 3.11`
    - `jsonpatch`

```
# Potentially need to install pip3 first
dnf install -y python3-pip

pip3 install boto3>=1.34.0 botocore>=1.34.0 kubernetes>=24.2.0 pyyaml>=3.11 jsonpatch
```

```
$ pip3 freeze | grep -i -e boto -e kubernetes -e pyyaml -e jsonpatch
boto3==1.42.56
botocore==1.42.56
jsonpatch==1.33
kubernetes==34.1.0
PyYAML==6.0.2
```

## `aws`

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```
dnf install -y awscli2 || apt install -y awscli
```

## `openshift-install` and `oc`

The most simple way is to download the `openshift-install` and `oc` binaries directly from the OpenShift mirrors at the link below.
The current installation is centered around stable-4.20 however you may be able to get away with changing the version (4.19+ required for GA Gateway API).

https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable-4.20/

`openshift-install`:
- openshift-install-linux.tar.gz

`oc` (rhel 8/9 dependent):
- openshift-client-linux-amd64-rhel8.tar.gz
- openshift-client-linux-amd64-rhel9.tar.gz

Where/how you place them is up to you - bins and aliases should both work fine.

```
$ which openshift-install oc
~/.local/bin/openshift-install
~/.local/bin/oc
```

```
$ alias openshift-install="/path/to/openshift-install"
$ alias oc="/path/to/oc"

$ which openshift-install oc
alias openshift-install='/path/to/openshift-install'
alias oc='/path/to/oc'
```

## `skupper`

The skupper cli can be installed by navigating to the binary download at Red Hat, or by visiting its opensource page and choosing from a binary or an all-in-one curl command.

The Red Hat RHSI binary is recommended as we are using OpenShift and RHSI directly, not an opensource skupper install.

https://access.redhat.com/jbossnetwork/restricted/listSoftware.html?downloadType=distributions&product=redhat.service.interconnect

(https://access.redhat.com/downloads -> Red Hat Service Interconnect)

https://skupper.io/v1/install/

## Secrets

### An SSH Key for OCP
```
ssh-keygen -f secrets/id_rsa_ocp
```

### A Pull Secret and Public SSH Key (secrets.yml)

Required:
- Your Red Hat Pull Secret (ipi_pull_secret)
- The Public SSH Key From id_rsa_ocp (ipi_ssh_key)

```
cp secrets/secrets.yml.example secrets/secrets.yml
vim secrets/secrets.yml
```

# Demo Quickstart
1. Run `aws configure --profile sandboxXYZ`
   (or create `~/.aws/config` and `~/.aws/credentials` files, or your preferred path with related export statements)

```
$ aws configure --profile sandboxXYZ
AWS Access Key ID [None]: Paste AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: Paste AWS_SECRET_ACCESS_KEY
Default region name [None]: None
Default output format [None]: ANY
```

**NOTE: Keeping the "Default region name: None" ensures the vars.yml is respected and the playbook never falls back to an unintended region in the event of any bugs or sloppy coding.**

2. `cd demo/aws`

3. `AWS_PROFILE=sandboxXYZ ansible-playbook -i inventory/clusters.yml demo.yml`

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
AWS_PROFILE=sandboxXYZ ansible-playbook -i inventory/clusters.yml demo.yml --tags deploy_argo_apps,approve_install_plans,deploy_rhsi_tokens
```
