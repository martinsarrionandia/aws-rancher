data "template_file" "rancher" {
  template = file("${path.module}/templates/rancher-boot.tpl")
  vars = {
    bootstrap_password = var.bootstrap_password
    acme_domain = "${var.host_name}.${var.domain_name}"
    rancher_admin_http = var.rancher_admin_http
    rancher_admin_https = var.rancher_admin_https
    ambassador_node_port_http = var.ambassador_node_port_http
    ambassador_node_port_https = var.ambassador_node_port_https
  }
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
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = "sarrionandia-eu-w2"
  root_block_device {
    volume_size               = "12"
  }
  associate_public_ip_address = false
  user_data                   = data.template_file.rancher.rendered
  subnet_id                   = aws_subnet.rancher.id
  vpc_security_group_ids      = [aws_security_group.rancher.id]


  tags = {
    Name = "Rancher host"
  }
}

resource "aws_eip" "rancher" {
  network_interface = aws_instance.rancher.primary_network_interface_id
  vpc      = true
  depends_on = [aws_instance.rancher]
}