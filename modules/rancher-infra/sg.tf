resource "aws_security_group" "this_mgmt" {
  name        = "${var.env-name} Rancher Mgmt"
  description = "Allow Rancher Management and Web"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "this_mgmt_ssh" {
  description       = "Permit managment SSH"
  security_group_id = aws_security_group.this_mgmt.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.ip-allowlist
}

resource "aws_security_group_rule" "this_mgmt_kube_api" {
  description              = "Permit kube api between cluster nodes"
  security_group_id        = aws_security_group.this_mgmt.id
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.this_mgmt.id
}

resource "aws_security_group_rule" "outbound_all" {
  description       = "Permit outbound all"
  security_group_id = aws_security_group.this_mgmt.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "this_ingress" {
  name        = "${var.env-name} Rancher Ingress"
  description = "Allow Ingress traffic to cluster"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "this_ingress_icmp" {
  description       = "Permit ICMP to cluster"
  security_group_id = aws_security_group.this_ingress.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "this_ingress_http" {
  description       = "Permit HTTP to cluster"
  security_group_id = aws_security_group.this_ingress.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "this_ingress_https" {
  description       = "Permit HTTPS to cluster"
  security_group_id = aws_security_group.this_ingress.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}