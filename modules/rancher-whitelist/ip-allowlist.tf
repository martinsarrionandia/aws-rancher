resource "null_resource" "ip-allowlist" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/martin/.ssh/sarrionandia-eu-w2.pem")
    host        = data.terraform_remote_state.rancher-infra.outputs.fqdn
    agent       = false
    timeout     = "10s"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/ip-allowlist.yaml", {
      ip-allowlist = local.ip-allowlist
    })
    destination = "/tmp/ip-allowlist.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/kubectl apply -f /tmp/ip-allowlist.yaml"
    ]
  }
}

locals {

  ip-allowlist = setunion(
    var.ip-allowlist-additional,
    ["${chomp(data.http.my_current_ip.response_body)}/32"]
  )
}