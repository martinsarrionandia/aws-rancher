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
find . -type f -name 'remote.tf' -or -name 'backend.tf' -exec sed -i 's/sarrionandia.co.uk/$BUCKETNAME/g' {} \;
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

In the componenet order: rancher-infra, rancer-bootstrap then rancher-config perform;

```bash
terraform apply
``` 

   
