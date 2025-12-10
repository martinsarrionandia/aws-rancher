output "rancher-role-arn" {
  value = aws_iam_role.this.arn
}

output "region" {
  value = var.region
}

output "s3-prefix-list-id" {
  value = aws_vpc_endpoint.this_s3.prefix_list_id
}

output "s3-whitelist" {
  value = local.ip_range
}

output "domain-name" {
  value = data.aws_route53_zone.this.name
}

output "instance-profile" {
  value = aws_iam_instance_profile.this.id
}

output "subnet-id" {
  value = aws_subnet.this.id
}

output "security-groups" {
  value = { mgmt = aws_security_group.this_mgmt.id,
  ingress = aws_security_group.this_ingress.id }
}
