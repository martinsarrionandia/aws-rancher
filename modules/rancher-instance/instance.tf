resource "aws_instance" "this" {
  availability_zone = var.availability-zone
  ami               = data.aws_ami.centos9.id
  instance_type     = data.aws_ec2_instance_type.this.instance_type
  key_name          = var.instance-key-name
  root_block_device {
    volume_size = var.volume-size
    encrypted   = true
    tags = {
      Name    = local.fqdn
      Rancher = "True"
    }
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "2"
  }

  iam_instance_profile = var.instance-profile
  user_data = templatefile("${path.module}/templates/rancher_boot.sh",
    {
      bootstrap-password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["bootstrap"],
      acme-domain        = local.fqdn,
      cluster-issuer     = var.cluster-issuer,
      letsencrypt-email  = var.letsencrypt-email,
      ip-allowlist       = "${chomp(data.http.my_current_ip.response_body)}/32",
  })

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }

  tags = {
    Name        = local.fqdn
    Rancher     = "True"
    Environment = var.env-name
  }

  provisioner "local-exec" {
    command = "ssh-keygen -R ${self.tags.Name}"
    when    = destroy
  }
}

resource "aws_network_interface" "this" {
  subnet_id       = var.subnet-id
  security_groups = var.security-groups
  tags = {
    Name        = "primary_network_interface"
    Environment = var.env-name
  }
}

resource "aws_eip" "this" {
  network_interface = aws_network_interface.this.id
}