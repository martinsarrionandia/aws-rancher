resource "aws_security_group" "rancher" {
  name        = "Rancher"
  description = "Allow Rancher Management and Web"
  vpc_id      = aws_vpc.container.id
}

resource "aws_security_group_rule" "racher_ssh" {
  security_group_id = aws_security_group.rancher.id
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.rancher.id
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.rancher.id
  type              = "ingress"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "racher_admin_http" {
  security_group_id = aws_security_group.rancher.id
  type              = "ingress"
  from_port         = 0
  to_port           = var.rancher_admin_http
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "racher_admin_https" {
  security_group_id = aws_security_group.rancher.id
  type              = "ingress"
  from_port         = 0
  to_port           = var.rancher_admin_https
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  security_group_id = aws_security_group.rancher.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
