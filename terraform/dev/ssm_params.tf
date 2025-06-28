resource "aws_ssm_parameter" "db_ip" {
  name  = "/dev/db/MYSQL_HOST"
  type  = "String"
  value = aws_instance.db.private_ip
}
