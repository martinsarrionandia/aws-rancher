resource "aws_ssm_association" "rancher" {
  name = aws_ssm_document.apply_middlware.name

  targets {
    key    = "InstanceIds"
    values = var.instance_ids
  }
}

resource "aws_ssm_parameter" "ip-allow-list" {
  name  = "${var.env_name}-ipAllowList"
  type  = "String"
  value = join(", ", local.ip-allowlist)
}

resource "aws_ssm_document" "apply_middlware" {
  name            = "${var.env_name}-apply_ip_allowlist_middleware"
  document_format = "YAML"
  document_type   = "Command"
  content         = local.apply_middleware_document
  lifecycle {
    replace_triggered_by = [
      aws_ssm_parameter.ip-allow-list
    ]
  }
}

locals {
  apply_middleware_document = <<EOF
schemaVersion: '2.2'
description: runShellScript with command strings stored as Parameter Store parameter
parameters:
  ipAllowList:
    type: String
    description: Required The list of ip IDCRs
    default: "{{ssm:${aws_ssm_parameter.ip-allow-list.name}}}"
mainSteps:
- action: aws:runShellScript
  name: runShellScriptDefaultParams
  inputs:
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
          sourceRange: [{{ ipAllowList }}]
      DOC
      sudo -i kubectl apply -f /root/allowlist.yaml
EOF
}
