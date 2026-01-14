resource "aws_vpc_endpoint" "this_s3" {
  vpc_id          = aws_vpc.this.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.this.id]
  tags = {
    Name        = "S3 Endpoint"
    Environment = var.env_name
  }
}