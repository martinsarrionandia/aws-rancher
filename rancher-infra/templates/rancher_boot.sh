#!/bin/bash

#ENV
export LOCAL_IPV4=$(ec2-metadata -o --quiet)
export PUBLIC_IPV4=$(ec2-metadata -v --quiet)

# Set hostname
sudo hostnamectl set-hostname "${acme-domain}"

# Add local bin to path

cat > /etc/profile.d/localpath.sh << EOF
export export PATH=/usr/local/bin:$PATH
EOF

chmod 644 /etc/profile.d/localpath.sh

# Update DNF

sudo dnf update -y

# Install Tools

sudo dnf install -y net-tools iotop nc iptables git policycoreutils-python-utils

# Kernel settings

export KERNEL_PARAM_FILE=/etc/sysctl.d/90-kubelet.conf

cat > "$KERNEL_PARAM_FILE" << EOF
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
EOF

sysctl -p "$KERNEL_PARAM_FILE"

# Set log labels

#semanage fcontext -a -t container_file_t -r s0 /var/log
semanage fcontext -a -t container_file_t -r s0 /var/log/containers
semanage fcontext -a -t container_file_t -r s0 /var/log/pods
restorecon -R /var/log

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


# Install kubectl

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

export TRAEFIK_PLUGINS_PATH=/mnt/traefik-plugins
mkdir $TRAEFIK_PLUGINS_PATH
chown 65532:65532 $TRAEFIK_PLUGINS_PATH
chmod 700 $TRAEFIK_PLUGINS_PATH
semanage fcontext -a -t container_file_t -r s0 $TRAEFIK_PLUGINS_PATH

kubectl create namespace traefik

cat > /root/traefik-volume.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: traefik-plugins
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-path
  local:
    path: $TRAEFIK_PLUGINS_PATH
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - "${acme-domain}"
EOF

kubectl apply -f /root/traefik-volume.yaml

cat > /root/traefik-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: traefik
  name: traefik-plugins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
  volumeName: traefik-plugins
EOF

kubectl apply -f /root/traefik-pvc.yaml


cat > /root/traefik-plugins.yaml << EOF
experimental:
  plugins:
    rewrite-body:
      moduleName: "github.com/packruler/rewrite-body"
      version: "v1.2.0"
    crowdsec-bouncer-traefik-plugin:
      moduleName: "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin"
      version: "v1.3.5"
EOF

helm install traefik traefik/traefik \
  --version 33.1.0-rc1 \
  --namespace traefik \
  --set-json deployment.additionalVolumes='[{"name": "plugins","persistentVolumeClaim": {"claimName": "traefik-plugins"}}]' \
  --set-json additionalVolumeMounts='[{"name": "plugins","mountPath": "/plugins-storage"}]' \
  --set providers.kubernetesCRD.enabled=true \
  --set securityContext.seccompProfile.type=RuntimeDefault \
  --set-json service.spec='{"externalTrafficPolicy":"Local"}' \
  --values traefik-plugins.yaml.yaml

# Install Cert Manager

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager --namespace cert-manager --set crds.enabled=true


# Create IP Whitelist for rancher/API access

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

#Intall Rancher

kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname="${acme-domain}" \
  --set bootstrapPassword="${bootstrap-password}" \
  --set letsEncrypt.ingress.class=traefik \
  --set letsEncrypt.email="${letsencrypt-email}" \
  --set ingress.extraAnnotations."traefik\.ingress\.kubernetes\.io\/router\.middlewares"="middleware-rancher-ip-allowlist@kubernetescrd" \
  --set ingress.tls.source=letsEncrypt

# set selinux label for /var/log to be readable by all containers. This is required for Crowdsec

chcon -R system_u:object_r:container_file_t:s0 /var/log/


# kubectl patch svc traefik -p '{"spec":{"externalTrafficPolicy":"Local"}}' -n kube-system