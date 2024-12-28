data "http" "my_current_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance-type
}

data "aws_ami" "centos9" {
  owners      = ["125523088429"]
  most_recent = true
  name_regex  = "CentOS Stream 9"

  filter {
    name   = "architecture"
    values = data.aws_ec2_instance_type.this.supported_architectures
  }
}
