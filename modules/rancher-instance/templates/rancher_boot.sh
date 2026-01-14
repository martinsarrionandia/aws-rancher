#!/bin/bash

# Set hostname

hostnamectl set-hostname "${acme-domain}"

# Add local bin to path

cat > /etc/profile.d/localpath.sh << EOF
export export PATH=/usr/local/bin:$PATH
EOF
chmod 644 /etc/profile.d/localpath.sh

# Update DNF

dnf update -y

# Install Tools

dnf install -y net-tools iotop nc iptables git policycoreutils-python-utils awscli

# Install AWS Session Manager

export ARCH=$(hostnamectl |grep Architecture|awk '{print $2}')

dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_$ARCH/amazon-ssm-agent.rpm

# Fetch IP address use aws cli

export INSTANCE_ID=$(cat /var/lib/cloud/data/instance-id)

export LOCAL_IPV4=$(aws ec2 describe-network-interfaces --filters "Name=attachment.instance-id,Values=$INSTANCE_ID" --query NetworkInterfaces[0].PrivateIpAddress --output text)
export PUBLIC_IPV4=$(aws ec2 describe-network-interfaces --filters "Name=attachment.instance-id,Values=$INSTANCE_ID" --query NetworkInterfaces[0].Association.[PublicIp] --output text)


# Kernel security settings

export KERNEL_PARAM_FILE=/etc/sysctl.d/90-kubelet.conf

cat > "$KERNEL_PARAM_FILE" << EOF
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
EOF

sysctl -p "$KERNEL_PARAM_FILE"

# Install POD Security Admission policy

export KUBELET_PSA_DIR="/var/lib/rancher/k3s/server"
export KUBELET_PSA_FILE="psa.yaml"
export KUBELET_PSA_PATH=$KUBELET_PSA_DIR/$KUBELET_PSA_FILE

mkdir -p $KUBELET_PSA_DIR

cat > "$KUBELET_PSA_PATH" << EOF
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: PodSecurity
  configuration:
    apiVersion: pod-security.admission.config.k8s.io/v1beta1
    kind: PodSecurityConfiguration
    defaults:
      enforce: "restricted"
      enforce-version: "latest"
      audit: "restricted"
      audit-version: "latest"
      warn: "restricted"
      warn-version: "latest"
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces: [kube-system, cis-operator-system, cattle-system,cattle-provisioning-capi-system, cattle-fleet-system, cattle-fleet-local-system, fleet-default]
EOF

# Install K3S

export K3S_SCRIPT="k3s.sh"

curl -sfLo $K3S_SCRIPT https://get.k3s.io
chmod 755 $K3S_SCRIPT
./$K3S_SCRIPT  --protect-kernel-defaults --selinux \
                       --kube-apiserver-arg="admission-control-config-file=$KUBELET_PSA_PATH" \
                       --disable traefik
#--node-external-ip="$PUBLIC_IPV4"  
#--advertise-address="$LOCAL_IPV4"

echo "Waiting for K3S to start"

while ! nc -z localhost 6443; do   
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "K3S Running"
sleep 10

# Install KUBECONFIG profile setting

cat > /etc/profile.d/kubeconfig.sh << EOF
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
EOF

chmod 644 /etc/profile.d/kubeconfig.sh

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install HELM

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Repos

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Install Traefik v3

kubectl create namespace traefik

helm install traefik traefik/traefik \
  --set replicas=-1 \
  --namespace traefik \
  --set securityContext.seccompProfile.type=RuntimeDefault \
  --set-json service.spec='{"externalTrafficPolicy":"Local"}'

# Install Cert Manager

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager --namespace cert-manager --set crds.enabled=true

# Create IP Allowlist for rancher API access

kubectl create namespace middleware

export ALLOWLIST=/root/allowlist.yaml

cat > $ALLOWLIST << EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace: middleware
  name: rancher-ip-allowlist
spec:
  ipAllowList:
    sourceRange:  
      - "${ip-allowlist}"
EOF

kubectl apply -f $ALLOWLIST

# Intall Rancher

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set replicas=-1 \
  --set hostname="${acme-domain}" \
  --set bootstrapPassword="${bootstrap-password}" \
  --set letsEncrypt.ingress.class=traefik \
  --set letsEncrypt.email="${letsencrypt_email}" \
  --set ingress.extraAnnotations."traefik\.ingress\.kubernetes\.io\/router\.middlewares"="middleware-rancher-ip-allowlist@kubernetescrd" \
  --set ingress.tls.source=letsEncrypt

# set selinux labels for /var/log to be readable by all containers. This is required for Crowdsec

#semanage fcontext -a -t container_file_t -r s0 /var/log
#semanage fcontext -a -t container_file_t -r s0 /var/log/containers
#semanage fcontext -a -t container_file_t -r s0 /var/log/pods
#restorecon -R /var/log

chcon system_u:object_r:container_file_t:s0 /var/log
chcon -R system_u:object_r:container_file_t:s0 /var/log/containers
chcon -R system_u:object_r:container_file_t:s0 /var/log/pods

# kubectl patch svc traefik -p '{"spec":{"externalTrafficPolicy":"Local"}}' -n kube-system