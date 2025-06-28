data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_ro_role" {
  name = var.s3_ro_role_name

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

}

resource "aws_iam_instance_profile" "s3_ro_profile" {
  name = var.s3_ro_role_name
  role = aws_iam_role.s3_ro_role.name
}

resource "aws_iam_role_policy" "policy" {
  name = "S3-RO"
  role = aws_iam_role.s3_ro_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:DescribeJob",
          "s3:Get*",
          "s3:List*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
} 