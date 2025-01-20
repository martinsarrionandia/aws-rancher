resource "aws_ssm_association" "rancher" {
  name = aws_ssm_document.apply_middlware.name

  targets {
    key    = "InstanceIds"
    values = var.instance-ids
  }
}

resource "aws_ssm_document" "apply_middlware" {
  name            = "apply_ip_allowlist_middleware"
  document_format = "YAML"
  document_type   = "Command"
  content         = local.apply_middleware_document
}

locals {
  apply_middleware_document = <<EOF
schemaVersion: '1.2'
description: Apply ip allowlist for rancher API access
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
        - |
          sudo tee /root/allowlist.yaml > /dev/null <<'DOC'
          apiVersion: traefik.io/v1alpha1
          kind: Middleware
          metadata:
            namespace: middleware
            name: rancher-ip-allowlist
          spec:
            ipWhiteList:
              sourceRange: %{for ip in local.ip-allowlist}
              - ${ip} %{endfor}
          DOC
          sudo -i kubectl apply -f /root/allowlist.yaml
EOF
}