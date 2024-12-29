data "http" "my_current_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "http" "aws_ip_ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
}