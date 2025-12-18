# AWS Demo Steps

## Edit the vars.yml to include your `sandbox_domain`, and any customizations

```
vim vars.yml
```

## Create an OCP SSH Key

```
ssh-keygen -f secrets/id_rsa_ocp
```

## Create secrets/secrets.yml with the appropriate secrets

Required:
- Your Red Hat Pull Secret (ipi_pull_secret)
- The Public SSH Key From id_rsa_ocp (ipi_ssh_key)

```
cp secrets/secrets.yml.example secrets/secrets.yml
vim secrets/secrets.yml
```

## Run with automatic profile

```
AWS_PROFILE=$(cat vars.yml | grep sandbox_domain | sed 's/sandbox_domain: //' | sed 's/\..*/"/') ansible-playbook demo.yml
```

## Run with manual profile

```
AWS_PROFILE=example ansible-playbook demo.yml
```
