resource "helm_release" "external-dns-aws" {
  namespace  = kubernetes_namespace_v1.external-dns-aws.metadata[0].name
  name       = var.external_dns_name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  set = [{
    name = "policy"
    #value = "sync"
    value = "upsert-only"
    },
    {
      name  = "replicaCount"
      value = local.external_dns_replicas
    },
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "crd.create"
      value = "true"
    },
    {
      name  = "provider"
      value = "aws"
    },
    {
      name  = "aws.region"
      value = var.region
      }, {
      name  = "aws.roleArn"
      value = var.rancher_role_arn
  }]

  values = [yamlencode(local.external-dns-values)]

}

locals {
  external-dns-values = {
    resources = {
      requests = {
        cpu = "25m"
      }
    }
    env = [
      {
        name  = "AWS_DEFAULT_REGION"
        value = var.region
      }
    ]
  }
}