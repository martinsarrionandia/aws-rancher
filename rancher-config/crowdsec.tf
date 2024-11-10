resource "helm_release" "crowdsec" {
  namespace  = "kube-system"
  name       = var.crowdsec-name
  repository = "https://crowdsecurity.github.io/helm-charts"
  chart      = "crowdsec"
  values     = [local.crowdsec-helm-values]
}

resource "kubernetes_manifest" "crowdsec-middlewarre" {
  manifest = yamldecode(local.crowdsec-middleware-config)
}

locals {

crowdsec-middleware-config = <<EOF
apiVersion: traefik.io/v1alpha1
#apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
    name: crowdsec-bouncer-traefik-plugin
    namespace: middleware
spec:
    plugin:
        crowdsec-bouncer-traefik-plugin:
            CrowdsecLapiKey: "${jsondecode(data.aws_secretsmanager_secret_version.rancher-current.secret_string)["bouncer-key-traefik"]}"
            Enabled: "true"
EOF

crowdsec-helm-values = <<EOF
# for raw logs format: json or cri (docker|containerd)
container_runtime: containerd
agent:
  # Specify each pod whose logs you want to process
  acquisition:
    # The namespace where the pod is located
    - namespace: traefik
      # The pod name
      podName: traefik-*
      # as in crowdsec configuration, we need to specify the program name to find a matching parser
      program: traefik
  env:
    - name: COLLECTIONS
      value: "crowdsecurity/traefik"
lapi:
  env:
    # To enroll the Security Engine to the console
    - name: ENROLL_KEY
      value: "${jsondecode(data.aws_secretsmanager_secret_version.rancher-current.secret_string)["crowdsec-enroll-key"]}"
    - name: ENROLL_INSTANCE_NAME
      value: "${data.terraform_remote_state.rancher-infra.outputs.fqdn}"
    - name: ENROLL_TAGS
      value: "rancher"
    - name: BOUNCER_KEY_traefik
      value: "${jsondecode(data.aws_secretsmanager_secret_version.rancher-current.secret_string)["bouncer-key-traefik"]}"
  resources:
    limits:
      cpu: 500m
      memory: 500Mi
    requests:
      cpu: 50m
      memory: 250Mi

EOF

}