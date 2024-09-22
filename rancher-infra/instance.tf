data "aws_ami" "ubuntu_x64" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"

  filter {
    name   = "architecture"
    values = ["x86_64"]

  }
  #ami-0194c3e07668a7e36
}

data "aws_ami" "ubuntu_arm64" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"

  filter {
    name   = "architecture"
    values = ["arm64"]

  }
  #ami-0194c3e07668a7e36
}

resource "aws_instance" "rancher" {
  availability_zone = var.availability_zone
  ami               = data.aws_ami.ubuntu_x64.id
  instance_type     = "t3.medium"
  key_name          = var.instance_key_name
  root_block_device {
    volume_size = "16"
    tags = {
      Name    = local.fqdn
      Rancher = "True"
    }
  }

  iam_instance_profile = aws_iam_instance_profile.rancher.id
  user_data = templatefile("${path.module}/templates/rancher_boot.sh",
    {
      bootstrap_password      = jsondecode(data.aws_secretsmanager_secret_version.rancher_admin_current.secret_string)["admin"],
      acme_domain             = "${var.host_name}.${var.domain_name}",
      rancher_ip              = local.rancher_ip,
      rancher_admin_http      = var.rancher_admin_http,
      rancher_admin_https     = var.rancher_admin_https,
      traefik_node_port_http  = var.traefik_node_port_http,
      traefik_node_port_https = var.traefik_node_port_https,
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
  private_ips     = [local.rancher_ip]
  tags = {
    Name = "primary_network_interface"
    Name = "Rancher"
  }
}


resource "aws_eip" "rancher" {
  network_interface = aws_network_interface.rancher.id
}

locals {
  rancher_ip         = cidrhost(var.rancher_subnet_cidr, 10)
  rancher_ingress_ip = cidrhost(var.rancher_subnet_cidr, 11)
}