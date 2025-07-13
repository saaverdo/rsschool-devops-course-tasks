locals {
  k3s_master_ip = aws_instance.k3s_master.private_ip
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "k3s_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small" #var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.my_app_profile.name
  vpc_security_group_ids      = [local.sg_k3s_id]
  subnet_id                   = module.vpc.private_subnets[0]
  user_data_base64 = base64encode(templatefile("${path.module}/../files/bootstrap/deploy_k3s.tpl", {
    region = var.aws_region
  }))

  tags = {
    Name = "k3s_master"
  }
  depends_on = [null_resource.dummy]
}


resource "aws_instance" "k3s_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small" #var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.my_app_profile.name
  vpc_security_group_ids      = [local.sg_k3s_id]
  subnet_id                   = module.vpc.private_subnets[0]
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli 
              for i in  {1..7}; do
              TOKEN=$(aws ssm get-parameter --name "/dev/k3s/node-token" --region ${var.aws_region} --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
              [[ -n $TOKEN ]] && break
              sleep 5
              done
              curl -sfL https://get.k3s.io | K3S_URL=https://${local.k3s_master_ip}:6443 K3S_TOKEN="$TOKEN" sh -
              EOF

  tags = {
    Name = "k3s_worker"
  }
  depends_on = [aws_instance.k3s_master]
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.my_app_profile.name
  vpc_security_group_ids      = [local.sg_bastion_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli 
              aws s3 cp s3://${var.backup_bucket_name}/bootstrap/deploy_kubectl.sh /tmp/deploy_kubectl.sh
              EOF

  tags = {
    Name = "Bastion"
  }
  depends_on = [aws_s3_bucket_object.bootstrap]
}

resource "null_resource" "dummy" {
  provisioner "local-exec" {
    command = "echo ${module.vpc.private_nat_gateway_route_ids[0]}"
  }
}
