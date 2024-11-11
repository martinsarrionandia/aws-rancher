resource "aws_instance" "rancher" {
  availability_zone = var.availability-zone
  ami               = data.aws_ami.centos9_arm64.id
  instance_type     = "t4g.large"
  key_name          = var.instance-key-name
  root_block_device {
    volume_size = "32"
    tags = {
      Name    = local.fqdn
      Rancher = "True"
    }
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "2"
  }

  iam_instance_profile = aws_iam_instance_profile.rancher.id
  user_data = templatefile("${path.module}/templates/rancher_boot.sh",
    {
      bootstrap-password = jsondecode(data.aws_secretsmanager_secret_version.rancher-current.secret_string)["bootstrap"],
      acme-domain        = "${var.host-name}.${var.domain-name}",
      rancher-ip         = local.rancher-ip,
      cluster-issuer     = var.cluster-issuer,
      letsencrypt-email  = var.letsencrypt-email,
      ip-whitelist       = "${chomp(data.http.my_current_ip.response_body)}/32",
      public-ip          = aws_eip.rancher.public_ip
  })

  network_interface {
    network_interface_id = aws_network_interface.rancher.id
    device_index         = 0
  }

  tags = {
    Name    = local.fqdn
    Rancher = "True"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -R ${self.tags.Name}"
    when    = destroy
  }
}

resource "aws_network_interface" "rancher" {
  subnet_id       = aws_subnet.rancher.id
  security_groups = [aws_security_group.rancher_mgmt.id, aws_security_group.rancher_ingress.id]
  private_ips     = [local.rancher-ip]
  tags = {
    Name = "primary_network_interface"
    Name = "Rancher"
  }
}

resource "aws_eip" "rancher" {
  network_interface = aws_network_interface.rancher.id
}

locals {
  rancher-ip = cidrhost(var.rancher-subnet-cidr, 10)
}