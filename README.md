# aws-rancher

Builds an environment, single node rancher instance and some useful stuff. Manages required IAM policies, basic IP whitelist security, EBS storage drivers, letencrypt, external-dns and kubectl config file.

###

# Requirements

 * [terraform binary](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

 * [Taskfile.dev](https://taskfile.dev/)

 * [AWS Account](https://aws.amazon.com/)

 * [Route53](https://aws.amazon.com/route53/) Hosted Zone

 * [s3](https://aws.amazon.com/s3/) Bucket for state files

 * [Secret Manager](https://aws.amazon.com/secrets-manager/) To store the passw0rdz.txt

 * [t4g](https://aws.amazon.com/ec2/instance-types/t4/) large instance. 8GB of ram is required for a single node isntance. Anything less results in pod restarts.

## Setup

This guide will walk you though an example configuration as follows;

- Work Environemnt: cattle-prod
- Region: ew-west-2
- Availability Zone: ew-west-2a
- DNS dmoain: sarrionandia.co.uk
- Hostname: rancher
- S3 state bucket: tf-state.sarrionandia.co.uk
- AWS Secret: myranchersecret
- EC2 Private key name: sarrionandia-eu-w2


### Getting started

- Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- Configure an IAM admin user in the [console](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html)

- Download and stash the Key ID and Access Key

- Type the following command to configure credentials and region. You will be prompted for input if this is a first time setup.

```bash
aws configure

AWS Access Key ID: ENTER THE KEY ID
AWS Secret Access Key: ENTER THE ACCESS KEY
Default region name: eu-west-2 (for London)
Default output format: json
```

- Create an S3 Bucket using the aws cli. This bucket is for the state file. Buckets are private by default. Keep a copy of the output name for later.

```bash
echo -n "Enter domain name:"
read DOMAIN
export BUCKET="tf-state.$DOMAIN"
aws s3 mb s3://"$BUCKET"
```

- Create a secret called using the aws cli. Remember to change the values *consolepassword*, *adminpassword* and *rootpassword* .These values will be used to set your passwords during deployment later.

```bash
aws secretsmanager create-secret \
    --name myranchersecret \
    --description "Rancher secrets" \
    --secret-string "{\"admin\":\"adminpassword\",\"root\":"\rootpassword\",\"bootstrap\":\"bootstrappassword\"}"
```

Secrets are region specific. If you have set the region above with 'aws configure' that's where it will reside.

Grab the secret ARN and stash it for later.

- Create a route53 zone for the domain where you will host rancher. In this example, I have already created *sarrionandia.co.uk*

- Create an Instnace Key Pair and take note of the name. You will need to set this in the variables below.

```bash
aws ec2 create-key-pair \
    --key-name sarrionandia-eu-w2 \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > ~/.ssh/sarrionandia-eu-w2.pem
```

- Add a section to (Taskfile.yaml)

Multiple configurations can deployed through the use of include sections in (Taskfile.yaml). We will be working on *cattle-prod*.

```yaml
includes:
  cattle-prod:
    taskfile: ./Taskfile.defs.yaml
    vars:
      WORKSPACE: cattle-prod
      AWS_ACCOUNT_ID: 281287281094
      AWS_ACCOUNT_NAME: 'sarrionandia.co.uk'
      AWS_PROFILE: 'default'
      AWS_ROLE_ARN: 'arn:aws:iam::{{.AWS_ACCOUNT_ID}}:user/martin'
```

- Change the following variable values in

(vars/common.tfvars)
(vars/cattle-prod.tfvars)

- instance-key-name
- domain-name
- letsencrypt-email
- rancher-secret-arn
- domain-name
- hostname
- rancher-secret-arn
- instance-key-name

These are already configured for the exmaple data above. Change these to suit your needs.

(variables.tf) Contains some default values which can be overriden in (vars/common.tfvars) and (vars/cattle-prod.tfvars)

 *Note*

  It's best not to manage any secret data with terraform as the contents are stored in an S3 bucket. Even if it's encrypted. As we are not storing nuclear launch codes, we will make an exception due to laziness. 

# Components

## rancher-infra

Creates everything you need to host the rancher software.

 * VPC
 * Subnet
 * Route Table
 * Internet GW
 * IAM Policies
 * S3 Endpoint

## rancher-instance

 * Elastic IP
 * EC2 Instance
 * Initial IP Allowlist for API access

The k3s/rancher installation will be performed by the cloud-init user data bootstrap shell script

## rancher-bootstrap

This componenet will "bootstrap" the rancher server and set the admin password. Once complete, it will generate a local [kubectl config file] (https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

This componenet will run only once. The bootstarp token will be invalided shortly after. This is by design.

You may then proceed to interact with kubernetes using the kubectl command.

This componenet is not th same thing as user data bootstrap, which is performed in the previous componenet.

## rancher-config

This componenet installs and configures

 * [aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)

    Required for mounting EBS volumnes directly into pods

 * [external-dns](https://github.com/kubernetes-sigs/external-dns)

    Creates DNS entries from kubernetes manfiest annontations

 * [cluster issuer](https://cert-manager.io/docs/configuration/acme/)

    Creates a letsencrypt cluster issuer

 * [traefik ip-whitelist](https://doc.traefik.io/traefik/middlewares/http/ipwhitelist/)

    Manages a traefik IP Whitelist to restrict access to the rancher API

 * [crowdsec WAF](https://www.crowdsec.net/)

    Install Crowdsec threat intelligence and middleware componenet. Reouting is optional, see example deployments below.

# Instructions

## Build

Use the `task` command to apply configuration

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

Set the varialbes: *traefik-log-level* to DEBUG.

[rancher-config/variables.tf](rancher-config/variables.tf)

Apply terrafrom.

```bash
task cattle-prod:apply
```
Get the logs from the traefik pod

```bash
kubectl get pods -n kube-system

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

kubectl logs --follow traefik-fb6486f5-p46dx -n kube-system

"-" 157071 "websecure-matrix-matrix-matrix-synapse-matrix-sarrionandia-co-uk-matrix@kubernetes" "http://10.42.0.53:8008" 1ms
185.77.56.38 - - [19/Oct/2024:10:25:33 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx HTTP/2.0" 200 8606 "-" "-" 157073 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.15:80" 4ms
185.77.56.38 - - [19/Oct/2024:10:25:33 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx/log?container=traefik HTTP/2.0" 200 8171850 "-" "-" 157074 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.13:80" 930ms
10.42.0.1 - - [19/Oct/2024:10:25:36 +0000] "GET /ping HTTP/1.1" 200 2 "-" "-" 157075 "ping@internal" "-" 0ms
10.42.0.1 - - [19/Oct/2024:10:25:36 +0000] "GET /ping HTTP/1.1" 200 2 "-" "-" 157076 "ping@internal" "-" 0ms
185.77.56.38 - - [19/Oct/2024:10:25:41 +0000] "GET /k8s/clusters/local/api/v1/namespaces/kube-system/pods/traefik-fb6486f5-p46dx HTTP/2.0" 200 8606 "-" "-" 157077 "websecure-cattle-system-rancher-rancher-sarrionandia-co-uk@kubernetes" "http://10.42.0.14:80" 4ms
```

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
