resource "kubernetes_namespace_v1" "external_dns_aws" {
  metadata {
    name = "extertnal-dns-aws"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}

resource "kubernetes_namespace_v1" "crowdsec" {
  metadata {
    name = "crowdsec"
    labels = {
      "pod-security.kubernetes.io/enforce" = var.crowdsec_privileged ? "privileged" : "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}

resource "kubernetes_namespace_v1" "proxy" {
  metadata {
    name = "proxy"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}