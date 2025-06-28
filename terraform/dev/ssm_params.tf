resource "aws_ssm_parameter" "k3s_master_ip" {
  name  = "/dev/k3s/master_ip"
  type  = "String"
  value = local.k3s_master_ip
}
