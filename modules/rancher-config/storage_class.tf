resource "kubernetes_storage_class" "amazon-ebs" {
  metadata {
    name = var.amazon-ebs-class
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  parameters = {
    type = "pd-standard"
  }
  #mount_options = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}