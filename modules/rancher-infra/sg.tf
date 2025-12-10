resource "aws_security_group" "this_mgmt" {
  name        = "${var.env-name} Rancher Mgmt"
  description = "Allow Rancher Management and Web"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "mgmt-${var.env-name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_mgmt_ssh" {
  for_each          = toset(local.ip-allowlist)
  description       = "Permit managment SSH"
  security_group_id = aws_security_group.this_mgmt.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  tags = {
    Name = "mgmt_ssh_${replace(each.value, "/", "_")}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_mgmt_kube_api" {
  description                  = "Permit kube api between cluster nodes"
  security_group_id            = aws_security_group.this_mgmt.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.this_mgmt.id
  tags = {
    Name = "mgmt_kube_api"
  }
}

resource "aws_vpc_security_group_egress_rule" "outbound_https" {
  description       = "Permit outbound all"
  security_group_id = aws_security_group.this_mgmt.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "outbound_https"
  }
}

resource "aws_vpc_security_group_egress_rule" "outbound_smtp" {
  description       = "Permit outbound all"
  security_group_id = aws_security_group.this_mgmt.id
  from_port         = 587
  to_port           = 587
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "outbound_smtp"
  }
}

resource "aws_security_group" "this_ingress" {
  name        = "${var.env-name} Rancher Ingress"
  description = "Allow Ingress traffic to cluster"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "ingress-${var.env-name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_ingress_icmp" {
  description       = "Permit ICMP to cluster"
  security_group_id = aws_security_group.this_ingress.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "ingress_icmp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_ingress_http" {
  description       = "Permit HTTP to cluster"
  security_group_id = aws_security_group.this_ingress.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "ingress_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_ingress_https" {
  description       = "Permit HTTPS to cluster"
  security_group_id = aws_security_group.this_ingress.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "ingress_https"
  }
}