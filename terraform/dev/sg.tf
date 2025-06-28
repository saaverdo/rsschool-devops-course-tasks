locals {
  ingress_web_rules = {
    http = { port = 80, protocol = "tcp" },
    app  = { port = 8000, protocol = "tcp" },
  }
  ingress_bastion_rules = {
    ssh = { port = 22, protocol = "tcp" },
  }
  ingress_k3s_rules = {
    api = { port = 6443, protocol = "tcp" },
    metrics = { port = 10250, protocol = "tcp" },
  }
  sg_web_id     = aws_security_group.sg_web.id
  sg_bastion_id = aws_security_group.sg_bastion.id
  sg_k3s_id      = aws_security_group.sg_k3s.id
}

data "aws_vpc" "this" {
  default = true
}

resource "aws_security_group" "sg_web" {
  name   = "sg_web"
  vpc_id = module.vpc.vpc_id

}
resource "aws_vpc_security_group_ingress_rule" "sg_web" {
  for_each = local.ingress_web_rules

  security_group_id = local.sg_web_id
  description       = each.key
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value.port
  ip_protocol       = each.value.protocol
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "sg_web" {
  security_group_id = local.sg_web_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "sg_bastion" {
  name   = "sg_bastion"
  vpc_id = module.vpc.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "sg_bastion" {
  for_each = local.ingress_bastion_rules

  security_group_id = local.sg_bastion_id
  description       = each.key
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value.port
  ip_protocol       = each.value.protocol
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "sg_bastion" {
  security_group_id = local.sg_bastion_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "sg_k3s" {
  name   = "sg_k3s"
  vpc_id = module.vpc.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "sg_k3s" {
  for_each = local.ingress_k3s_rules

  security_group_id            = local.sg_k3s_id
  description                  = each.key
  referenced_security_group_id = local.sg_k3s_id
  from_port                    = each.value.port
  ip_protocol                  = each.value.protocol
  to_port                      = each.value.port
}

resource "aws_vpc_security_group_ingress_rule" "sg_k3s_from_bastion" {

  security_group_id            = local.sg_k3s_id
  description                  = "Permit any from bastion"
  referenced_security_group_id = local.sg_bastion_id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "sg_k3s" {
  security_group_id = local.sg_k3s_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
