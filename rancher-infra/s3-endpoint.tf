resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.container.id
  service_name = "com.amazonaws.eu-west-1.s3"
  route_table_ids   = [aws_route_table.rancher.id]
  tags = {
    Name        = "S3 Endpoint"
    Environment = "Container"
  }
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id
}