#!/bin/bash

#ENV
export LOCAL_IPV4=$(ec2-metadata -o --quiet)
export PUBLIC_IPV4=$(ec2-metadata -v --quiet)

# SET hostname
sudo hostnamectl set-hostname "${acme-domain}"

# Add local bin to path

cat > /etc/profile.d/localpath.sh << EOF
export export PATH=/usr/local/bin:$PATH
EOF

chmod 644 /etc/profile.d/localpath.sh

# Update APT

sudo dnf update -y

# Install Tools

sudo dnf install -y net-tools iotop nc iptables git

# Network settings

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

sudo -i curl -sfLo $K3S_SCRIPT https://get.k3s.io
sudo -i chmod 755 $K3S_SCRIPT
sudo -i ./$K3S_SCRIPT  --protect-kernel-defaults --selinux \
                       --kube-apiserver-arg="admission-control-config-file=$KUBELET_PSA_PATH"
#--node-external-ip="$PUBLIC_IPV4"  
#--advertise-address="$LOCAL_IPV4"

echo "Waiting for K3S to start"

while ! nc -z localhost 6443; do   
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "K3S Running"
sleep 10


# Install kubectl

cat > /etc/profile.d/kubeconfig.sh << EOF
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
EOF

chmod 644 /etc/profile.d/kubeconfig.sh

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#Install HELM

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#Add Repos

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

#Install Cert Manager

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.15.3 --set crds.enabled=true

# Create IP Whitelist for rancher/API access

kubectl create namespace middleware

export WHITELIST=/root/whitelist.yaml

cat > $WHITELIST << EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  namespace: middleware
  name: rancher-ip-whitelist
spec:
  ipWhiteList:
    sourceRange:  
      - "${ip-whitelist}"
EOF

kubectl apply -f $WHITELIST

#Intall Rancher

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname="${acme-domain}" \
  --set bootstrapPassword="${bootstrap-password}" \
  --set ingress.extraAnnotations."traefik\.ingress\.kubernetes\.io\/router\.middlewares"="middleware-rancher-ip-whitelist@kubernetescrd" \
  --set letsEncrypt.ingress.class=traefik \
  --set letsEncrypt.email="${letsencrypt-email}" \
  --set ingress.tls.source=letsEncrypt

kubectl patch svc traefik -p '{"spec":{"externalTrafficPolicy":"Local"}}' -n kube-system