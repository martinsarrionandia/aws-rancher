data "aws_route53_zone" "rancher" {
  name         = "${var.domain-name}."
  private_zone = false
}

resource "aws_route53_record" "rancher" {
  zone_id = data.aws_route53_zone.rancher.zone_id
  name    = "${var.host-name}.${var.domain-name}"
  type    = "A"
  ttl     = "10"
  records = [aws_eip.rancher.public_ip]
}