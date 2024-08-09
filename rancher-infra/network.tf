resource "aws_subnet" "rancher" {
  availability_zone = var.availability_zone
  vpc_id            = aws_vpc.container.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Rancher subnet"
  }
}

resource "aws_route_table" "rancher" {
  vpc_id = aws_vpc.container.id

  tags = {
    Name = "Rancher route table"
  }
}

resource "aws_route_table_association" "rancher" {
  subnet_id      = aws_subnet.rancher.id
  route_table_id = aws_route_table.rancher.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.container.id

  tags = {
    Name = "Container VPC GW"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.rancher.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}