#!/bin/bash

#Update APT
sudo apt-get update && sudo apt-get -y upgrade

#Install Docker
sudo apt install net-tools -y
#sudo apt-get install docker.io -y
#sudo systemctl enable docker
#sudo systemctl start docker


#Install Rancher
sudo sysctl -w net/netfilter/nf_conntrack_max=131072

#net.bridge.bridge-nf-call-iptables=1

#sudo docker run -e CATTLE_BOOTSTRAP_PASSWORD='${bootstrap_password}' -d --restart=unless-stopped \
#-p 80:80 \
#-p 443:${traefik_node_port_https} \
#-p ${rancher_admin_http}:80 \
#-p ${rancher_admin_https}:443 \
#--privileged rancher/rancher:latest \
#--acme-domain "${acme_domain}"



curl -sfL https://get.k3s.io | sh -

curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubect


cat > /etc/profile.d/kubeconfig.sh << EOF
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
EOF

chmod 755 /etc/profile.d/kubeconfig.sh

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


sudo snap install helm --classic

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.11.01



helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname="${acme_domain}" \
  --set bootstrapPassword="${bootstrap_password}" \
  --set letsEncrypt.ingress.class=traefik \
  --set ingress.tls.source=letsEncrypt \



# --priviledged is required to remap 4434 to 443
#-p 80:${traefik_node_port_http} \