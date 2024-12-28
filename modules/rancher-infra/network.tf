resource "aws_subnet" "this" {
  availability_zone = var.availability-zone
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet-cidr

  tags = {
    Name = "${var.env-name} subnet"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env-name} route table"
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env-name} VPC GW"
  }
}

resource "aws_route" "this_internet" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}