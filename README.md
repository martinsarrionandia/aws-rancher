# aws-rancher

Builds an environemnt, single node rancher instance and some useful stuff. Manages required IAM policies, basic IP whitelist security, EBS storage drivers, letencrypt, external-dns and kubectl config file.

###

# Requirements

 * [terraform binary](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

 * [AWS Account](https://aws.amazon.com/)

 * [Route53](https://aws.amazon.com/route53/) Hosted Zone

 * [s3](https://aws.amazon.com/s3/) Bucket for state files

 * [Secret Manager](https://aws.amazon.com/secrets-manager/) To store the passw0rdz.txt

 * [t4g](https://aws.amazon.com/ec2/instance-types/t4/) large instance. 8GB of ram is required for a single node isntance. Anything less results in pod restarts.

## Setup

- Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- Configure an IAM admin user in the [console](https://docs.aws.amazon.com/streams/latest/dev/setting-up.html)

- Download and stash the Key ID and Access Key

- Type the follwoing command to configure credentials and region. You will be prompted for input if this is first time setup.

```bash
aws configure

AWS Access Key ID: ENTER THE KEY ID
AWS Secret Access Key: ENTER THE ACCESS KEY
Default region name: eu-west-2 (for London)
Default output format: json
```

- Create an S3 Bucket using the aws cli. This bucket is for the state file. In this example i've used my domain name sarrionandia.co.uk. Buckets are private by default.

```bash
aws s3api create-bucket --bucket sarrionandia.co.uk --region eu-west-2
```

- Create a secret called *rancher* using the aws cli. Remember to change the values *consolepassword*, *adminpassword* and *rootpassword* .These values will be used to set your passwords during deployment later.

```bash
aws secretsmanager create-secret \
    --name rancher \
    --description "Rancher secrets" \
    --secret-string "{\"admin\":\"adminpassword\",\"root\":"\rootpassword\",\"bootstrap\":\"bootstrappassword\"}"
```

Secrets are region specific. If you have set the region above with 'aws configure' that's where it will reside.

Grab the secret ARN and stash it for later.

- Create a route53 zone for the domain where you will host rancher. In this example I have already created *sarrionandia.co.uk*

- Create an Instnace Key Pair and remember take note of the name. You will need to set this in the variables beflow.

```bash
aws ec2 create-key-pair \
    --key-name sarrionandia-eu-w2 \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > ~/.ssh/sarrionandia-eu-w2.pem
```

- Change the following variable values in 

(rancher-infra/variables.tf)

 - region
 - availability-zone
 - instance-key-name
 - domain-name
 - letsencrypt-email
 - rancher-secret-arn

- Change the state bucket locations in the following files

[rancher-infra/backend.tf](rancher-infra/backend.tf)

[rancher-bootstrap/backend.tf](rancher-bootstrap/backend.tf)

[rancher-config/backend.tf](rancher-config/backend.tf)

[rancher-bootstrap/remote.tf](rancher-bootstrap/remote.tf)

[rancher-config/remote.tf](rancher-config/remote.tf)

Or just run this

```bash
export BUCKETNAME=stubbornstains.co.uk

find . -type f -name 'remote.tf' -exec sed -i '' -e "s/sarrionandia\.co\.uk/$BUCKETNAME/g" {} \;
find . -type f -name 'backend.tf' -exec sed -i '' -e "s/sarrionandia\.co\.uk/$BUCKETNAME/g" {} \;
```


 - Because of "reasons" my state bucket is in eu-west-1, but I'm deploying to eu-west-2 Change the bucket region if you have to.
 
 *Note*

  It's best not to manage any secret data with terraform as the contents are stored in an S3 bucket. Even if it's encrypted. As we are not storing nuclear launch codes we will make an exception due to lazyness. 

# Components

## rancher-infra

Creates everything you need to host the rancher software.

 * VPC
 * Subnet
 * Route Table
 * Internet GW
 * Elastic IP
 * EC2 Instance
 * Initial IP Whitelist
 * IAM Policies

The rancher installation will be performed by the cloud-init user daata bootsrap shell script

## rancher-bootstrap

This componenet will "bootstrap" the rancher serve and set the admin password. Once complete it will generate a local [kubectl config file] (https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

You may then proceed to interact with kubernetes using the kubectl command.

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

# Instructions

## Build

In the componenet order: rancher-infra, rancer-bootstrap then rancher-config perform;

```bash
terraform apply
``` 

## volumnes

After building the rancher server you will want to deploy some apps. To use persistent storage for these apps make sure you tag your volumes.

Make sure you create your volumes with the Tag `rancher=true` in order for the IAM policy to work

## Deployments

Here are some example deployments to get you going...

[matrix](https://github.com/martinsarrionandia/matrix)

[wordpress](https://github.com/martinsarrionandia/mojobooth.co.uk)

## Update IP Whitelist

Due to "reasons" it is not recommended to run rancher on a different port to 443. Restricting access to rancher with a SG is therefore not practical.

Alternatives include using a AWS ELB which is expensive. 

However an basic IP Whitelist can be applied via traefik middleware.

During the deploymenty your laptop public IP is automatically added to the SG for ssh and rancher ip whitelist. If this changes you will be locked out.

To update the ssh SG source reapply terrafrom in rancher-infra componenet. 

Then you can run the [rancher-config/apply-ip-whitelist.sh](rancher-config/apply-ip-whitelist.sh) script

You will need to manually point the private key to your EC2 key pair here [rancher-config/ip-whitelist.tf](rancher-config/ip-whitelist.tf)

## Turn on Traefik Logs

Set the varialbes: *traefik-log-level* to DEBUG and *traefik-access-log* to true

[rancher-config/variables.tf]rancher-config/variables.tf

Apply terrafrom in the rancher-config component

```bash
terraform apply
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


