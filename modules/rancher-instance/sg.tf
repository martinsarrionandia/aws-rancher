resource "aws_vpc_security_group_egress_rule" "outbound_http" {
  description       = "Permit outbound ACME Self Check"
  security_group_id = var.security_groups.mgmt
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "${aws_eip.this.public_ip}/32"
  tags = {
    Name = "outbound_http_acme_test"
  }
}