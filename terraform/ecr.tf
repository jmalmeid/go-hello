
locals {
  tags_ecr = {
    Deploy     = var.name_ecr
    Team       = "devops"
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# ECR Repository
################################################################################

module "ecr_disabled" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ecr.git"

  create = false
}

module "ecr" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ecr.git"

  repository_name = var.name_ecr

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags_ecr
}

################################################################################
# ECR Registry
################################################################################

data "aws_iam_policy_document" "registry" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ecr:ReplicateImage",
    ]

    resources = [
      module.ecr.repository_arn,
    ]
  }
}

module "ecr_registry" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ecr.git"

  create_repository = false

  # Registry Policy
  create_registry_policy = true
  registry_policy        = data.aws_iam_policy_document.registry.json

  # Registry Pull Through Cache Rules
  registry_pull_through_cache_rules = {
    pub = {
      ecr_repository_prefix = "ecr-public"
      upstream_registry_url = "public.ecr.aws"
    }
  }

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = true
  registry_scan_type                     = "ENHANCED"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
      }, {
      scan_frequency = "CONTINUOUS_SCAN"
      filter         = "example"
      filter_type    = "WILDCARD"
    }
  ]

  # Registry Replication Configuration
  create_registry_replication_configuration = true
  registry_replication_rules = [
    {
      destinations = [{
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
        }, {
        region      = "eu-west-1"
        registry_id = data.aws_caller_identity.current.account_id
      }]

      repository_filters = [{
        filter      = "prod-microservice"
        filter_type = "PREFIX_MATCH"
      }]
    }
  ]

  tags = local.tags_ecr
}
