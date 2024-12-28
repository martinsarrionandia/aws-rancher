resource "helm_release" "crowdsec" {
  namespace  = var.crowdsec-namespace
  name       = var.crowdsec-name
  repository = "https://crowdsecurity.github.io/helm-charts"
  chart      = "crowdsec"
  values     = [local.crowdsec-helm-values]

  set {
    name  = "agent.resources.limits.memory"
    value = "250Mi"
  }

  set {
    name  = "agent.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "agent.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "agent.resources.requests.memory"
    value = "250Mi"
  }
}

resource "kubernetes_manifest" "crowdsec-middlewarre" {
  manifest = yamldecode(local.crowdsec-middleware-config)
}

locals {

  crowdsec-middleware-config = <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: ${var.bouncer}
  namespace: ${var.traefik-namespace}
spec:
  plugin:
    ${var.bouncer}:
      enabled: true
      crowdsecMode: stream
      lapi: enabled
      crowdsecLapiScheme: http
      crowdsecLapiHost: ${var.crowdsec-name}-service.${var.crowdsec-namespace}:8080
      CrowdsecLapiKey: "${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["bouncer-key-traefik"]}"
      crowdsecAppsecEnabled: false
      logLevel: ${var.traefik-log-level}
      clientTrustedips:
      %{for ip in local.ip-allowlist}
        - ${ip}
      %{endfor}
EOF

  crowdsec-helm-values = <<EOF
# for raw logs format: json or cri (docker|containerd)
container_runtime: containerd
agent:
  # Specify each pod whose logs you want to process
  acquisition:
    # The namespace where the pod is located
    - namespace: "${var.traefik-namespace}"
      # The pod name
      podName: traefik-*
      # as in crowdsec configuration, we need to specify the program name to find a matching parser
      program: traefik
  env:
    - name: COLLECTIONS
      value: "crowdsecurity/traefik"
lapi:
  dashboard:
    enabled: false
    image:
      repository: apollof/crowdsec_metabase
      tag: latest
  env:
    # To enroll the Security Engine to the console
    - name: ENROLL_KEY
      value: "${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["crowdsec-enroll-key"]}"
    - name: ENROLL_INSTANCE_NAME
      value: "${var.fqdn}"
    - name: ENROLL_TAGS
      value: "rancher"
    - name: BOUNCER_KEY_traefik
      value: "${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["bouncer-key-traefik"]}"
  resources:
    limits:
      cpu: 500m
      memory: 500Mi
    requests:
      cpu: 50m
      memory: 250Mi
appsec:
  enable: true

EOF
}