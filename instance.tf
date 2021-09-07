data "template_file" "rancher" {
  template = file("${path.module}/templates/rancher-boot.tpl")
  vars = {
    bootstrap_password = var.bootstrap_password
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

resource "aws_instance" "rancher" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = "t3.medium"
  key_name                    = "sarrionandia-eu-w2"
  associate_public_ip_address = true
  user_data                   = data.template_file.rancher.rendered
  subnet_id                   = aws_subnet.rancher.id
  vpc_security_group_ids      = [aws_security_group.rancher.id]


  tags = {
    Name = "Rancher host"
  }
}

resource "aws_eip" "rancher" {
  instance = aws_instance.rancher.id
  vpc      = true
}