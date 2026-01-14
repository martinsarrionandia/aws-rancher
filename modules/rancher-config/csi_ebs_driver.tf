resource "helm_release" "ebs-csi" {
  namespace  = "kube-system"
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  set = [
    {
      name  = "controller.replicaCount"
      value = local.ebs_csi_replicas
  }]
}