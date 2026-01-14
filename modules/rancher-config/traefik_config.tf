resource "helm_release" "traefik" {
  namespace  = var.traefik_namespace
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  #version         = "35.2.0"
  values          = [local.traefik-helm-manifest]
  replace         = true
  force_update    = true
  upgrade_install = true
  set = [
    {
      name  = "replicaCount"
      value = local.traefik_replicas
    }
  ]
}

locals {
  traefik-helm-manifest = <<EOF
deployment:
  additionalVolumes:
  - name: plugins
    persistentVolumeClaim:
      claimName: "${kubernetes_persistent_volume_claim_v1.traefik_plugins.metadata[0].name}"
additionalVolumeMounts:
- name: plugins
  mountPath: /plugins-storage
securityContext:
  seccompProfile:
    type: RuntimeDefault 
providers:
  kubernetesCRD:
    enabled: true
logs:
  general:
    level: "${var.traefik_log_level}"
    format: json
  access:
    enabled: ${var.traefik_access_log}
    format: json
service:
  spec:
    externalTrafficPolicy: "${var.traefik-external-access-policy}"
experimental:
  plugins:
    rewrite-body:
      moduleName: "github.com/packruler/rewrite-body"
      version: "v1.2.0"
    ${var.bouncer}:
      moduleName: "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin"
      version: "v1.3.5"
ingressRoute:
  dashboard:
    enabled: true
EOF
}