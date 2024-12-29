resource "kubernetes_namespace" "external-dns-aws" {
  metadata {
    name = "extertnal-dns-aws"
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
}