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

resource "aws_iam_role" "my_app_role" {
  name               = "app_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "my_app_profile" {
  name = "my_app_role"
  role = aws_iam_role.my_app_role.name
}

resource "aws_iam_role_policy_attachment" "S3ReadOnly_2_myapp_role" {
  role       = aws_iam_role.my_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "SSMInstanceCore_2_myapp_role" {
  role       = aws_iam_role.my_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
