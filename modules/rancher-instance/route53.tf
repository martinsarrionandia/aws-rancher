data "aws_route53_zone" "this" {
  name         = "${var.domain-name}."
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = "10"
  records = [aws_eip.this.public_ip]
}