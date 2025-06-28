locals {
  githubActionsRoles = [
    "AmazonEC2FullAccess",
    "AmazonRoute53FullAccess",
    "AmazonS3FullAccess",
    "IAMFullAccess",
    "AmazonVPCFullAccess",
    "AmazonSQSFullAccess",
    "AmazonEventBridgeFullAccess",
    "AmazonSSMFullAccess",
  ]

}

resource "aws_iam_role" "gh_actions_role" {
  name = var.GHA_role_name

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_gha.json

  tags = {
    Project = "rs-devops"
  }
}

data "aws_iam_policy_document" "assume_role_policy_gha" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com", ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_account}/${var.github_repo}:*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "gh_actions_role" {
  for_each   = toset(local.githubActionsRoles)
  role       = aws_iam_role.gh_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
