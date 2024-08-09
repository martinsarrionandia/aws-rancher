# Hopefully not required for mounting EBS volumes. TBC.
#resource "rancher2_cloud_credential" "foo" {
#  name        = "foo"
#  description = "foo test"
#  amazonec2_credential_config {
#    access_key = "<AWS_ACCESS_KEY>"
#    secret_key = "<AWS_SECRET_KEY>"
#  }
#}