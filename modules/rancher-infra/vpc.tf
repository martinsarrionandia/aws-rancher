resource "aws_vpc" "this" {
  cidr_block = var.subnet_cidr

  tags = {
    Name = "${var.env_name} VPC"
  }
}