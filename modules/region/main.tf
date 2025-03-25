terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name            = var.name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0"

  name     = var.name
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.private_subnets
  internal = true

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  client_keep_alive = 7200

  listeners = {

    ex-http-weighted-target = {
      protocol = "HTTP"
      weighted_forward = {
        target_groups = [
          {
            target_group_key = "ex-lambda-without-trigger"
            weight           = 100
          },
        ]
      }
    }
  }

  target_groups = {
    ex-lambda-without-trigger = {
      name_prefix              = "l2-"
      target_type              = "lambda"
      target_id                = module.lambda.lambda_function_arn
      attach_lambda_permission = true
    }
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  function_name                = var.name
  cloudwatch_logs_skip_destroy = true
  handler                      = "lambda.handler"
  runtime                      = "nodejs22.x"
  source_path = [
    "${path.module}/lambda.mjs"
  ]

  vpc_subnet_ids                     = module.vpc.private_subnets
  vpc_security_group_ids             = [module.vpc.default_security_group_id]
  attach_network_policy              = true
  replace_security_groups_on_destroy = true
  replacement_security_group_ids     = [module.vpc.default_security_group_id]
}

output "alb_arn" {
  value = module.alb.arn
}