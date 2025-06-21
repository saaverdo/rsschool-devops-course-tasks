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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.my_app_profile.name
  vpc_security_group_ids = [local.sg_web_id, local.sg_db_id]
  subnet_id = module.vpc.public_subnets[1]
  associate_public_ip_address = true
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli pkg-config libmysqlclient-dev
              aws s3 cp s3://${var.backup_bucket_name}/bootstrap/deploy_app.sh /tmp/deploy_app.sh
              aws s3 cp s3://${var.backup_bucket_name}/bootstrap/myapp.service /tmp/myapp.service
              AWS_REGION=${var.aws_region} bash /tmp/deploy_app.sh
              EOF
  
  tags = {
    Name = "Web_server"
  }
  depends_on = [aws_instance.db]
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.s3_ro_profile.name
  vpc_security_group_ids = [local.sg_bastion_id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion"
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.my_app_profile.name
  vpc_security_group_ids = [local.sg_db_id]
  subnet_id = module.vpc.private_subnets[1]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli
              aws s3 cp s3://${var.backup_bucket_name}/bootstrap/deploy_db.sh /tmp/deploy_db.sh
              bash /tmp/deploy_db.sh
              EOF
  tags = {
    Name = "DB_server"
  }
  depends_on = [aws_s3_bucket_object.bootstrap, null_resource.dummy]
}

resource "null_resource" "dummy" {
  provisioner "local-exec" {
    command = "echo ${module.vpc.private_nat_gateway_route_ids[0]}"
  }
}
