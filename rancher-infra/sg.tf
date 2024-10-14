data "http" "my_current_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "rancher_mgmt" {
  name        = "Rancher Mgmt"
  description = "Allow Rancher Management and Web"
  vpc_id      = aws_vpc.container.id
}

resource "aws_security_group_rule" "racher_ssh" {
  security_group_id = aws_security_group.rancher_mgmt.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.my_current_ip.response_body)}/32"]
}

resource "aws_security_group_rule" "k3s_6443" {
  security_group_id = aws_security_group.rancher_mgmt.id
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["${aws_eip.rancher.public_ip}/32"]
}

resource "aws_security_group_rule" "outbound_all" {
  security_group_id = aws_security_group.rancher_mgmt.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "rancher_ingress" {
  name        = "Rancher Ingress"
  description = "Allow Ingress traffic to cluster"
  vpc_id      = aws_vpc.container.id
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.rancher_ingress.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.rancher_ingress.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_http" {
  # Allow traefik to ACME service
  security_group_id = aws_security_group.rancher_ingress.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}