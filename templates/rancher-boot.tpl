#!/bin/bash

#Install Docker
sudo yum -y install docker
sudo systemctl enable docker
sudo systemctl start docker

#Install Rancher
sudo docker run -e CATTLE_BOOTSTRAP_PASSWORD="${bootstrap_password}" -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher