
# aws-rancher

Builds an environment, single-node Rancher instance, and some useful tools. Manages required IAM policies, basic IP whitelist security, EBS storage drivers, Let's Encrypt, external-dns, CrowdSec security, and kubectl config file.

---

## Requirements

To get started, make sure you have the following:

- **[Terraform binary](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)**
- **[Taskfile.dev](https://taskfile.dev/)**
- **[AWS Account](https://aws.amazon.com/)**
- **[Route53](https://aws.amazon.com/route53/) Hosted Zone**
- **[S3](https://aws.amazon.com/s3/) Bucket for state files**
- **[Secrets Manager](https://aws.amazon.com/secrets-manager/)** for storing `passw0rdz.txt`
- **[t4g](https://aws.amazon.com/ec2/instance_types/t4/)** large EC2 instance (8GB of RAM required for a single-node instance; anything less results in pod restarts)
- **[Crowdsec Enroll Key](https://www.crowdsec.net/)** Sign up for a free tier account

---

## Setup

This guide walks you through configuring the following example environment:

- **Work Environment**: `cattle-prod`
- **Region**: `eu-west-2`
- **Availability Zone**: `eu-west-2a`
- **DNS Domain**: `sarrionandia.co.uk`
- **Hostname**: `rancher`
- **S3 State Bucket**: `tf-state.sarrionandia.co.uk`
- **AWS Secret**: `myranchersecret`
- **EC2 Private Key Name**: `sarrionandia-eu-w2`

### Getting Started

1. **Install AWS CLI**:
   Follow the installation guide for the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

2. **Configure IAM Admin User**:
   Set up an IAM admin user in the [AWS Console](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html).

3. **Configure AWS CLI**:
   Run the following command to configure your credentials and region:

    ```bash
    aws configure

    AWS Access Key ID: ENTER THE KEY ID
    AWS Secret Access Key: ENTER THE ACCESS KEY
    Default region name: eu-west-2 (for London)
    Default output format: json
    ```

4. **Create an S3 bucket for the state file**: This bucket is private by default.

    ```bash
    echo -n "Enter domain name: "
    read DOMAIN
    export BUCKET="tf-state.$DOMAIN"
    aws s3 mb s3://"$BUCKET"
    ```

5. **Create Secrets Manager Secret**: Replace adminpassword, rootpassword, and bootstrappassword with your actual passwords.

    ```bash
    aws secretsmanager create-secret \
        --name myranchersecret \
        --description "Rancher secrets" \
        --secret-string '{"admin":"adminpassword","root":"rootpassword","bootstrap":"bootstrappassword"}'
    ```

    Secrets are region-specific. Take note of the secret ARN for later user.

6. **Create a Route 53 zone for the domain**: Set up a Route53 hosted zone for the domain where you will host Rancher. Example domain: sarrionandia.co.uk

7. **Create an EC2 key pair**: Generate an EC2 key pair for SSH access:

    ```bash
    aws ec2 create-key-pair \
        --key-name sarrionandia-eu-w2 \
        --key-type rsa \
        --key-format pem \
        --query "KeyMaterial" \
        --output text > ~/.ssh/sarrionandia-eu-w2.pem
    ```

8. **Configure Taskfile**:
   Modify `Taskfile.yaml` to include your configuration. The following example shows the inclusion for `cattle-prod`.

    ```yaml
    includes:
      cattle-prod:
        taskfile: ./Taskfile.defs.yaml
        vars:
          WORK_ENV: cattle-prod
          AWS_ACCOUNT_ID: 281287281094
          AWS_ACCOUNT_NAME: "sarrionandia.co.uk"
          AWS_PROFILE: "default"
          AWS_ROLE_ARN: "arn:aws:iam::{{.AWS_ACCOUNT_ID}}:user/martin"
    ```

> **_NOTE:_** Multiple configurations can deployed through the use of include sections in `Taskfile.yaml`. Copy and paste the `cattle-prod` seciton to `cattle-dev` for an additional dev environemnt. Make sure the `WORK_ENV` var matches the section title and is unique.

9. **Update Variable Values**:
   Change the necessary variables in the following files:
   - `vars/common.tfvars`
   - `vars/cattle-prod.tfvars`

    Specifically, modify values for:
    - `instance_key_name`
    - `domain_name`
    - `letsencrypt_email`
    - `rancher_secret_arn`
    - `hostname`

   Defaults are configured for the example data but can be adjusted as needed.

> **_NOTE:_** We are storing secrets in the Terraform state files located on S3. Although the bucket is private and data is encrypted, this is far from ideal. 

We can not deploy direct secret mangement until the cluster is bootstrapped. Once the cluster is bootstrapped you can optionaly use;

[https://github.com/aws/secrets-store-csi-driver-provider-aws](https://github.com/aws/secrets-store-csi-driver-provider-aws)

This will avoid storing further secrets in the state file.

## Components Overview

### rancher-infra
This component sets up everything required to host Rancher:

- VPC
- Subnet
- Route Table
- Internet Gateway
- IAM Policies
- S3 Endpoint

### rancher-instance
This component provisions:

- Elastic IP
- EC2 Instance
- SE Linux configuration
- K3S and Rancher
- Traefik 3 Ingress controller
- Initial IP Allowlist for API access

### rancher-bootstrap
Bootstraps the Rancher server and sets the admin password. This component generates a local [kubectl config file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

> **_NOTE:_** This component runs only once, and the bootstrap token expires shortly after. This bootstrap is not to be confued with EC2 Bootstrapping.

The `kubectl` filename is the fqdn. To use the specific cluster ensure you configure you ENV as the default file is `config`;

```bash
export KUBECONFIG="${HOME}/.kube/rancher.sarrionandia.co.uk"
```

### rancher-config
Installs and configures several components, including:

- [aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver): Mounts EBS volumes into pods
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Manages DNS entries
- [cluster issuer](https://cert-manager.io/docs/configuration/acme/): Manages Let's Encrypt certificates
- [traefik IP whitelist](https://doc.traefik.io/traefik/middlewares/http/ipwhitelist/): Restricts access to Rancher API
- [Crowdsec WAF](https://www.crowdsec.net/): Threat intelligence and security middleware

---

## Instructions

### Build

Use the `task` command to apply the configuration:

```bash
task cattle-prod:init
task cattle-prod:apply
```
## Persistent Volumes

After building the rancher server, you will want to deploy some apps. To use persistent storage for these apps, make sure you tag your volumes.

Tag `rancher=true` in order for the IAM policy to work

## Deployments

Here are some example deployments to get you going...

[matrix](https://github.com/martinsarrionandia/matrix)

[wordpress](https://github.com/martinsarrionandia/mojobooth.co.uk)

## Update IP Allowlist

This is currently a mess and will be re-engineering with AWS Session Manager shotrly...

Due to "reasons" it is not recommended to run rancher on a different port to 443. Restricting access to rancher with an SG is therefore not practical.

Alternatives include using a AWS ELB which is expensive.

However, a basic IP Allowlist can be applied via traefik middleware.

During the deploymenty your laptop/pipeline public IP is automatically added to the SG for ssh and rancher ip allowlist. If this changes you will be locked out.

To update the ssh SG source reapply terrafrom for rancher-infra componenet.

Then SSH onto your server.

edit /root/allowlist.yaml

Modify the IP address.

then run 

```bash
kubectl apply -f /root/allowlist.yaml
```

## Turn on Traefik DEBUG Logs

By default traefik is configured to log INFO level events.

Set the varialbes: *traefik_log_level* to DEBUG.

[rancher-config/variables.tf](rancher-config/variables.tf)

Apply terrafrom.

```bash
task cattle-prod:apply
```
Get the logs from the traefik pod

```bash
kubectl get pods -n traefik

NAME                                      READY   STATUS      RESTARTS   AGE
coredns-7b98449c4-cl666                   1/1     Running     0          2d11h
ebs-csi-controller-86f5545569-bs24x       5/5     Running     0          2d10h
ebs-csi-controller-86f5545569-tnrkq       5/5     Running     0          2d10h
ebs-csi-node-45j7l                        3/3     Running     0          2d10h
helm-install-traefik-52fql                0/1     Completed   0          2d10h
helm-install-traefik-crd-7pv8r            0/1     Completed   0          2d11h
local-path-provisioner-6795b5f9d8-9sh7w   1/1     Running     0          2d11h
metrics-server-cdcc87586-dm4db            1/1     Running     0          2d11h
svclb-traefik-33578b2c-bbf8n              2/2     Running     0          2d11h
traefik-fb6486f5-p46dx

kubectl logs --follow traefik-fb6486f5-p46dx -n traefik

"-" 157071 "websecure-matrix-matrix-matrix-synapse-matrix-sarrionandia-co-uk-matrix@kubernetes" "http://10.42.0.53:8008" 1ms
185.77.56.38 - - [19/Oct/2024:10:25:33 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx HTTP/2.0" 200 8606 "-" "-" 157073 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.15:80" 4ms
185.77.56.38 - - [19/Oct/2024:10:25:33 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx/log?container=traefik HTTP/2.0" 200 8171850 "-" "-" 157074 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.13:80" 930ms
10.42.0.1 - - [19/Oct/2024:10:25:36 +0000] "GET /ping HTTP/1.1" 200 2 "-" "-" 157075 "ping@internal" "-" 0ms
10.42.0.1 - - [19/Oct/2024:10:25:36 +0000] "GET /ping HTTP/1.1" 200 2 "-" "-" 157076 "ping@internal" "-" 0ms
185.77.56.38 - - [19/Oct/2024:10:25:41 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx HTTP/2.0" 200 8606 "-" "-" 157077 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.14:80" 4ms
```

---

# Useful commands

## Access the traefik dashboard

There is no default ingress for the dashbaord, so you will need to create one or just tunnel the traffic.

kubectl can perform port forwarding in the same way as an SSH Tunnel.

To access the traefik dashboard enter the following command on your laptop. The will route 8080 on your laptop to the traefik pod port 8080 where the dashbaord is running.

```bash
kubectl --namespace=traefik port-forward $(kubectl get pods --namespace=traefik --selector "app.kubernetes.io/name=traefik" --output=name) 8080:8080
```

Leave the terminal running...

Then browse to;

[http://localhost:8080/dashboard/#/](http://localhost:8080/dashboard/#/)
