resource "kubernetes_namespace" "external-dns-aws" {
  metadata {
    name = "extertnal-dns-aws"
  }
}

resource "kubernetes_namespace" "crowdsec" {
  metadata {
    name = "crowdsec"
  }
}