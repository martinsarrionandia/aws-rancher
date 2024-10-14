#!/bin/bash

#ENV
export LOCAL_IPV4=$(ec2-metadata -o --quiet)/32
export PUBLIC_IPV4=$(ec2-metadata -v --quiet)/32

#sudo apt-get update && sudo apt-get -y upgrade

sudo dnf update -y

#Install Tools

sudo dnf install -y net-tools iotop

#Network settings

sudo sysctl -w net/netfilter/nf_conntrack_max=131072

#Install K3S

export K3S_SCRIPT="k3s.sh"

sudo -i curl -sfLo $K3S_SCRIPT https://get.k3s.io
sudo -i chmod 755 $K3S_SCRIPT
sudo -i ./$K3S_SCRIPT --node-external-ip="${public-ip}"

#Install kubectl

cat > /etc/profile.d/kubeconfig.sh << EOF
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
EOF

chmod 755 /etc/profile.d/kubeconfig.sh

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
      - "10.0.0.0/8"
      - "$PUBLIC_IPV4"   
      - "${ip-whitelist}"
EOF

kubectl apply -f $WHITELIST

#Intall Rancher

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname="${acme-domain}" \
  --set bootstrapPassword="${bootstrap-password}" \
  --set ingress.extraAnnotations."traefik\.ingress\.kubernetes\.io\/router\.middlewares"="middleware-rancher-ip-whitelist@kubernetescrd"

  #--set letsEncrypt.ingress.class=traefik \
  #--set letsEncrypt.email="${letsencrypt-email}" \
  #--set ingress.tls.source=letsEncrypt

kubectl patch svc traefik -p '{"spec":{"externalTrafficPolicy":"Local"}}' -n kube-system