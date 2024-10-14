resource "kubernetes_namespace" "external-dns-aws" {
  metadata {
    name = "extertnal-dns-aws"
  }
}