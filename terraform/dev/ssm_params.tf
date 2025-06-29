resource "aws_ssm_parameter" "k3s_master_ip" {
  name  = "/dev/k3s/master_ip"
  type  = "String"
  value = local.k3s_master_ip
}

resource "aws_ssm_parameter" "k3s_config" {
  name  = "/dev/k3s/config"
  type  = "SecureString"
  value = ""
  lifecycle {
    ignore_changes = [value,key_id]
  }
}

resource "aws_ssm_parameter" "k3s_token" {
  name  = "/dev/k3s/node-token"
  type  = "SecureString"
  value = ""
  lifecycle {
    ignore_changes = [value,key_id]
  }
}
