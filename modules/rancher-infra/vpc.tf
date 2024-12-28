resource "aws_vpc" "this" {
  cidr_block = var.subnet-cidr

  tags = {
    Name = "${var.env-name} VPC"
  }
}