resource "kubernetes_namespace" "external-dns-aws" {
  metadata {
    name = "extertnal-dns-aws"
  }
  lifecycle {
    ignore_changes = [metadata[0].annotations["cattle.io/status"],
                      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"]]
  }
}

resource "kubernetes_namespace" "crowdsec" {
  metadata {
    name = "crowdsec"
    labels = {
      "pod-security.kubernetes.io/enforce" = var.crowdsec-privileged ? "privileged" : "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].annotations["cattle.io/status"],
                      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"]]
  }
}