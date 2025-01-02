resource "aws_iam_policy" "this_volume" {
  name   = "${var.env-name}_volume_policy"
  policy = templatefile("${path.module}/templates/volume_policy.json", {})
}

resource "aws_iam_policy" "this_external_dns" {
  name = "${var.env-name}_external_dns_policy"
  policy = templatefile("${path.module}/templates/external_dns_policy.json", {
    hosted_zone_id = data.aws_route53_zone.this.id
  })
}

resource "aws_iam_policy" "this_describe_network_interface" {
  name   = "${var.env-name}_ec2_describe_network_interface"
  policy = templatefile("${path.module}/templates/describe_network_interface.json", {})
}

resource "aws_iam_role" "this" {
  name               = "${var.env-name}_instance_role"
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

resource "aws_iam_role_policy_attachment" "this_volume" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this_volume.arn
}

resource "aws_iam_role_policy_attachment" "this_external_dns" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this_external_dns.arn
}

resource "aws_iam_role_policy_attachment" "this_describe_network_interface" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this_describe_network_interface.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.env-name}_rancher_profile"
  role = aws_iam_role.this.name
}
