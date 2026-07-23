data "aws_iam_policy_document" "release_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "environment_trust" {
  for_each = toset(["dev", "prod"])

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:environment:${each.key}"]
    }
  }
}

resource "aws_iam_role" "release" {
  name               = var.release_role_name
  assume_role_policy = data.aws_iam_policy_document.release_trust.json
  tags               = var.tags
}

resource "aws_iam_role" "environment" {
  for_each = {
    dev  = var.dev_role_name
    prod = var.prod_role_name
  }

  name               = each.value
  assume_role_policy = data.aws_iam_policy_document.environment_trust[each.key].json
  tags               = merge(var.tags, { DeploymentEnvironment = each.key })
}

data "aws_iam_policy_document" "release" {
  statement {
    sid       = "ECRAuthentication"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushAndReadReleaseImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = var.ecr_repository_arns
  }

  statement {
    sid    = "ManageReleaseRegistry"
    effect = "Allow"
    actions = [
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:PutParameter"
    ]
    resources = ["${var.ssm_parameter_arn_prefix}/releases/*"]
  }

  statement {
    sid       = "ListReleaseRegistry"
    effect    = "Allow"
    actions   = ["ssm:GetParametersByPath"]
    resources = ["${var.ssm_parameter_arn_prefix}/releases"]
  }

  statement {
    sid    = "ReadEnvironmentPointers"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["${var.ssm_parameter_arn_prefix}/environments/*/current-release"]
  }
}

resource "aws_iam_role_policy" "release" {
  name   = "${var.release_role_name}-policy"
  role   = aws_iam_role.release.id
  policy = data.aws_iam_policy_document.release.json
}

data "aws_iam_policy_document" "environment" {
  for_each = toset(["dev", "prod"])

  statement {
    sid       = "ECRAuthentication"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadReleaseImages"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]
    resources = var.ecr_repository_arns
  }

  statement {
    sid    = "ReadReleaseRegistry"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["${var.ssm_parameter_arn_prefix}/releases/*"]
  }

  statement {
    sid       = "ListReleaseRegistry"
    effect    = "Allow"
    actions   = ["ssm:GetParametersByPath"]
    resources = ["${var.ssm_parameter_arn_prefix}/releases"]
  }

  statement {
    sid    = "RecordEnvironmentDeployment"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "${var.ssm_parameter_arn_prefix}/environments/${each.key}/current-release",
      "${var.ssm_parameter_arn_prefix}/releases/*/tested/${each.key}"
    ]
  }

  statement {
    sid       = "DescribeDeploymentCluster"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [var.eks_cluster_arn]
  }
}

resource "aws_iam_role_policy" "environment" {
  for_each = toset(["dev", "prod"])

  name   = "${aws_iam_role.environment[each.key].name}-policy"
  role   = aws_iam_role.environment[each.key].id
  policy = data.aws_iam_policy_document.environment[each.key].json
}
