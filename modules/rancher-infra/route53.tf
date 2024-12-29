data "aws_route53_zone" "this" {
  name         = "${var.domain-name}."
  private_zone = false
}