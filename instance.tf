data "template_file" "rancher" {
  template = file("${path.module}/templates/rancher_boot.sh")
  vars = {
    bootstrap_password = jsondecode(data.aws_secretsmanager_secret_version.rancher_admin_current.secret_string)["admin"]
    acme_domain        = "${var.host_name}.${var.domain_name}"
    rancher_mgmt_ip    = local.rancher_mgmt_ip
    #rancher_ingress_ip = local.rancher_ingress_ip
    rancher_admin_http         = var.rancher_admin_http
    rancher_admin_https        = var.rancher_admin_https
    ambassador_node_port_http  = var.ambassador_node_port_http
    ambassador_node_port_https = var.ambassador_node_port_https
  }
  depends_on = [
    #aws_network_interface.rancher_ingress,
    aws_network_interface.rancher_mgmt
  ]
}

data "aws_ami" "amazon" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "amzn2-ami-hvm"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04"

  filter {
    name   = "architecture"
    values = ["x86_64"]

  }
  #ami-0194c3e07668a7e36
}

resource "aws_instance" "rancher" {
  availability_zone = var.availability_zone
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = "sarrionandia-eu-w2"
  root_block_device {
    volume_size = "16"
  }
  iam_instance_profile = aws_iam_instance_profile.rancher.id
  user_data = data.template_file.rancher.rendered

  network_interface {
    network_interface_id = aws_network_interface.rancher_mgmt.id
    device_index         = 0
  }

  #network_interface {
  #  network_interface_id = aws_network_interface.rancher_ingress.id
  #  device_index         = 1
  #}

  tags = {
    Name = local.fqdn
    Rancher = "True"
  }
}

resource "aws_network_interface" "rancher_mgmt" {
  subnet_id       = aws_subnet.rancher.id
  security_groups = [aws_security_group.rancher_mgmt.id, aws_security_group.rancher_ingress.id]
  private_ips     = [local.rancher_mgmt_ip]
  tags = {
    Name = "primary_network_interface"
    Name = "Rancher MGMT"
  }
}
#resource "aws_network_interface" "rancher_ingress" {
#  subnet_id       = aws_subnet.rancher.id
#  security_groups = [aws_security_group.rancher_ingress.id]
#  private_ips = [local.rancher_ingress_ip]
#  tags = {
#    Name = "secondary_network_interface"
#    Name = "Rancher Ingress"
#  }
#}

resource "aws_eip" "rancher_mgmt" {
  network_interface = aws_network_interface.rancher_mgmt.id
  vpc               = true
}

#resource "aws_eip" "rancher_ingress" {
#  network_interface = aws_network_interface.rancher_ingress.id
#  vpc      = true
#}

locals {
  rancher_mgmt_ip    = cidrhost(var.rancher_subnet_cidr, 10)
  rancher_ingress_ip = cidrhost(var.rancher_subnet_cidr, 11)
}