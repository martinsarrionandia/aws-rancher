resource "kubernetes_config_map_v1" "squid" {
  metadata {
    name      = "squid-config"
    namespace = kubernetes_namespace_v1.proxy.metadata[0].name
  }

  data = {
    squid = local.squid_config
  }
}

resource "kubernetes_manifest" "squid" {
  manifest = yamldecode(local.squid_manifest)
}

resource "kubernetes_service_v1" "squid" {
  metadata {
    name      = var.squid_name
    namespace = kubernetes_namespace_v1.proxy.metadata[0].name
  }
  spec {
    selector = {
      app = var.squid_name
    }
    port {
      port = var.squid_port
    }
  }
}

locals {
  squid_manifest = <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${var.squid_name}
  namespace: ${kubernetes_namespace_v1.proxy.metadata[0].name}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: squid
  template:
    metadata:
      labels:
        app: squid
    spec:
      containers:
      - name: squid
        image: ubuntu/squid:edge
        ports:
        - containerPort: 3128
          name: squid
          protocol: TCP
        volumeMounts:
        - name: squid-config-volume
          mountPath: /etc/squid/squid.conf
          subPath: squid.conf
      volumes:
        - name: squid-config-volume
          configMap:
            name: squid-config
            items:
            - key: squid
              path: squid.conf
  EOF

  squid_config = <<EOF
http_port ${var.squid_port}

acl SSL_ports port 443
acl Safe_ports port 80        # http
acl Safe_ports port 443       # https
acl CONNECT method CONNECT

# Reject local network
acl restricted_destination_subnetworks dst 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 127.0.0.0/8

# ---- WordPress.org allowlist (core/plugins/themes updates + downloads) ----
acl wordpress_org dstdomain .wordpress.org .w.org .s.w.org
acl elementor dstdomain .elementor.com
acl wpcode dstdomain .wpcode.com
acl trustindex dstdomain .trustindex.io
acl aioseo dstdomain .aioseo.com
acl google dstdomain .google.com .googleusercontent.com .googleapis.com
acl wpmail dstdomain .wpmailsmtp.com

# --- Disable ALL caching (disk + memory) ---
cache deny all
cache_mem 0 MB
maximum_object_size 0 KB
maximum_object_size_in_memory 0 KB
cache_dir null /tmp

# (Optional) reduce logging noise
# access_log none

# Deny requests to unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to ports other than 443
http_access deny CONNECT !SSL_ports

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# Block access to internal/private destinations
http_access deny restricted_destination_subnetworks

# Allow WordPress destinations
http_access allow wordpress_org
http_access allow elementor
http_access allow wpcode
http_access allow trustindex
http_access allow aioseo
http_access allow google
http_access allow wpmail

# Default deny
http_access deny all

# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid

# Do not display squid version
httpd_suppress_version_string on

EOF
}