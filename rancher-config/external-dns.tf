resource "helm_release" "external-dns-aws" {
  namespace  = kubernetes_namespace.external-dns-aws.metadata.0.name
  name       = var.external-dns-name
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "external-dns"

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "crd.create"
    value = "true"
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = data.terraform_remote_state.rancher-infra.outputs.region
  }

  set {
    name  = "aws.roleArn"
    value = data.terraform_remote_state.rancher-infra.outputs.rancher-role-arn
  }

  values = [yamlencode(local.external-dns-resource-limits)]

}

locals {
  external-dns-resource-limits = {
    resources = {
      requests = {
        cpu = "25m"
      }
    }
  }
}