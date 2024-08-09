#!/bin/bash

#Update APT
sudo apt-get update && sudo apt-get -y upgrade

#Install Docker
sudo apt install net-tools -y
sudo apt-get install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker


#Install Rancher
sudo sysctl -w net/netfilter/nf_conntrack_max=131072

sudo docker run -e CATTLE_BOOTSTRAP_PASSWORD='${bootstrap_password}' -d --restart=unless-stopped \
-p 80:80 \
-p 443:${emissary_node_port_https} \
-p ${rancher_admin_http}:80 \
-p ${rancher_admin_https}:443 \
--privileged rancher/rancher:latest \
--acme-domain "${acme_domain}"

#-p 80:${emissary_node_port_http} \