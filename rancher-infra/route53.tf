data "aws_route53_zone" "rancher" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "rancher" {
  zone_id = data.aws_route53_zone.rancher.zone_id
  name    = "${var.host_name}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.rancher.public_ip]
}