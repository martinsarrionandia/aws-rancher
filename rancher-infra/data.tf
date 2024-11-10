data "aws_ami" "amazon_arm64" {
  owners      = ["137112412989"]
  most_recent = true
  name_regex  = "al2023-ami"
  #name_regex  = "amzn2-ami"

  filter {
    name   = "architecture"
    values = ["arm64"]

  }
}

data "aws_ami" "ubuntu_arm64" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "aws_ami" "centos9_arm64" {
  owners      = ["125523088429"]
  most_recent = true
  name_regex  = "CentOS Stream 9"

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "http" "aws_ip_ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
}