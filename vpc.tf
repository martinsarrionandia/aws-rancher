resource "aws_vpc" "container" {
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Container VPC"
  }
}