resource "helm_release" "traefik" {
  namespace       = var.traefik-namespace
  name            = "traefik"
  repository      = "https://traefik.github.io/charts"
  chart           = "traefik"
  version         = "33.1.0"
  values          = [local.traefik-helm-manifest]
  replace         = true
  force_update    = true
  upgrade_install = true
}

locals {
  traefik-helm-manifest = <<EOF
deployment:
  additionalVolumes:
  - name: plugins
    persistentVolumeClaim:
      claimName: "${kubernetes_persistent_volume_claim.traefik_plugins.metadata[0].name}"
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
    level: "${var.traefik-log-level}"
  access:
    enabled: ${var.traefik-access-log}
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