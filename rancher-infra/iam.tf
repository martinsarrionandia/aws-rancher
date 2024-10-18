resource "aws_iam_policy" "rancher_volumes" {
  name   = "rancher_volume_policy"
  policy = templatefile("${path.module}/templates/rancher_volume_policy.json", {})
}

resource "aws_iam_policy" "rancher_external_dns" {
  name = "rancher_external_dns_policy"
  policy = templatefile("${path.module}/templates/rancher_external_dns_policy.json", {
    hosted_zone_id = data.aws_route53_zone.rancher.id
  })
}

resource "aws_iam_role" "rancher" {
  name               = "rancher_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rancher_volumes" {
  role       = aws_iam_role.rancher.name
  policy_arn = aws_iam_policy.rancher_volumes.arn
}

resource "aws_iam_role_policy_attachment" "rancher_external_dns" {
  role       = aws_iam_role.rancher.name
  policy_arn = aws_iam_policy.rancher_external_dns.arn
}

resource "aws_iam_instance_profile" "rancher" {
  name = "rancher_profile"
  role = aws_iam_role.rancher.name
}
