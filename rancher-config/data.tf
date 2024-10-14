data "http" "my_current_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "local_file" "kube_config" {
  filename        = pathexpand("~/.kube/config")
}