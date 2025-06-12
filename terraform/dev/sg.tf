locals {
  ingress_rules = {
    ssh = { port = 22, protocol = "tcp" },
    web = { port = 80, protocol = "tcp" },
  }
  sg_id = aws_security_group.sg_dev.id
}

data "aws_vpc" "this" {
  default = true
}

resource "aws_security_group" "sg_dev" {
  name   = "sg_dev_1"
  vpc_id = data.aws_vpc.this.id

}

resource "aws_security_group_rule" "ingress_rule" {
  for_each          = local.ingress_rules
  type              = "ingress"
  description       = each.key
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.sg_id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.sg_id
}
