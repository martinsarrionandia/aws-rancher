
# aws-rancher

Builds an environment, single-node Rancher instance, and some useful tools. Manages required IAM policies, basic IP whitelist security, EBS storage drivers, Let's Encrypt, external-dns, CrowdSec security, and kubectl config file.

## Requirements

* [Terraform binary](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Taskfile.dev](https://taskfile.dev/)
* [AWS Account](https://aws.amazon.com/)
* [Route 53](https://aws.amazon.com/route53/) Hosted Zone
* [S3](https://aws.amazon.com/s3/) Bucket for state files
* [Secrets Manager](https://aws.amazon.com/secrets-manager/) to store the `passw0rdz.txt`
* [t4g.large](https://aws.amazon.com/ec2/instance-types/t4/) EC2 instance (8GB RAM minimum for a single-node instance. Anything less will result in pod restarts).
* [CrowdSec](https://www.crowdsec.net/) enroll key (free tier available).

## Setup

This guide provides an example configuration as follows:

- **Work Environment**: cattle-prod
- **Region**: eu-west-2
- **Availability Zone**: eu-west-2a
- **DNS domain**: sarrionandia.co.uk
- **Hostname**: rancher
- **S3 state bucket**: tf-state.sarrionandia.co.uk
- **AWS Secret**: myranchersecret
- **EC2 Private Key Name**: sarrionandia-eu-w2

### Getting Started

1. Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

2. Configure an IAM admin user in the [AWS Console](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html).

3. Save the Key ID and Access Key, then configure credentials and region by running:

    ```bash
    aws configure

    AWS Access Key ID: ENTER THE KEY ID
    AWS Secret Access Key: ENTER THE ACCESS KEY
    Default region name: eu-west-2 (for London)
    Default output format: json
    ```

4. Create an S3 bucket for the state file:

    ```bash
    echo -n "Enter domain name: "
    read DOMAIN
    export BUCKET="tf-state.$DOMAIN"
    aws s3 mb s3://"$BUCKET"
    ```

5. Create a secret using the AWS CLI. Replace `consolepassword`, `adminpassword`, and `rootpassword` with your own values:

    ```bash
    aws secretsmanager create-secret \
        --name myranchersecret \
        --description "Rancher secrets" \
        --secret-string '{"admin":"adminpassword","root":"rootpassword","bootstrap":"bootstrappassword"}'
    ```

    Secrets are region-specific. Note the secret ARN for later.

6. Create a Route 53 zone for the domain. For this example, we use `sarrionandia.co.uk`.

7. Create an EC2 instance key pair:

    ```bash
    aws ec2 create-key-pair \
        --key-name sarrionandia-eu-w2 \
        --key-type rsa \
        --key-format pem \
        --query "KeyMaterial" \
        --output text > ~/.ssh/sarrionandia-eu-w2.pem
    ```

8. Update the `Taskfile.yaml` to include:

    ```yaml
    includes:
      cattle-prod:
        taskfile: ./Taskfile.defs.yaml
        vars:
          WORKSPACE: cattle-prod
          AWS_ACCOUNT_ID: 281287281094
          AWS_ACCOUNT_NAME: "sarrionandia.co.uk"
          AWS_PROFILE: "default"
          AWS_ROLE_ARN: "arn:aws:iam::{{.AWS_ACCOUNT_ID}}:user/martin"
    ```

9. Modify the following variables in:

    - `vars/common.tfvars`
    - `vars/cattle-prod.tfvars`

    Update:
    - `instance-key-name`
    - `domain-name`
    - `letsencrypt-email`
    - `rancher-secret-arn`
    - `hostname`

    Defaults are configured for the example data but can be adjusted as needed.

> **Note**: Avoid storing sensitive data like secrets in Terraform state files stored in S3. Although encrypted, it's better to use dedicated secrets management tools.

## Components

### rancher-infra

Creates the infrastructure needed to host Rancher:
- VPC
- Subnet
- Route Table
- Internet Gateway
- IAM Policies
- S3 Endpoint

### rancher-instance

Creates:
- Elastic IP
- EC2 instance
- Initial IP allowlist for API access

### rancher-bootstrap

Bootstraps the Rancher server, sets the admin password, and generates a local [kubectl config file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

### rancher-config

Installs and configures:
- [AWS EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)
- [Let's Encrypt Cluster Issuer](https://cert-manager.io/docs/configuration/acme/)
- [Traefik IP Whitelist](https://doc.traefik.io/traefik/middlewares/http/ipwhitelist/)
- [CrowdSec WAF](https://www.crowdsec.net/)

## Instructions

### Build

Use the `task` command to apply the configuration:

```bash
task cattle-prod:init
task cattle-prod:apply
```

### Persistent Volumes

Tag volumes with `rancher=true` to ensure IAM policy compatibility.

### Deployments

Example deployments:
- [Matrix](https://github.com/martinsarrionandia/matrix)
- [WordPress](https://github.com/martinsarrionandia/mojobooth.co.uk)

### Updating IP Allowlist

To update the IP allowlist, modify `/root/allowlist.yaml` on the server, then apply:

```bash
kubectl apply -f /root/allowlist.yaml
```

### Enable Traefik DEBUG Logs

Update the `traefik-log-level` variable to `DEBUG` in `rancher-config/variables.tf` and reapply:

```bash
task cattle-prod:apply
```

Retrieve logs:

```bash
kubectl logs --follow traefik-fb6486f5-p46dx -n kube-system
```

### Access the Traefik Dashboard

Set up port forwarding:

```bash
kubectl --namespace=traefik port-forward $(kubectl get pods --namespace=traefik --selector "app.kubernetes.io/name=traefik" --output=name) 8080:8080
```

Access the dashboard at [http://localhost:8080/dashboard/#/](http://localhost:8080/dashboard/#/).