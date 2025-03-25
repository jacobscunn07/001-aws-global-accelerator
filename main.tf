locals {
  name = "stormydonut"
  regions = {
    "us-east-1" : {
      name = "${local.name}-us-east-1"
      cidr = "10.0.0.0/16",
      azs = [
        "us-east-1a",
        "us-east-1b",
        "us-east-1c"
      ]
      private_subnets = [
        "10.0.0.0/24",
        "10.0.1.0/24",
        "10.0.2.0/24"
      ]
      public_subnets = [
        "10.0.3.0/24",
        "10.0.4.0/24",
        "10.0.5.0/24"
      ]
    },
    "ap-southeast-2" : {
      name = "${local.name}-ap-southeast-2"
      cidr = "10.1.0.0/16",
      azs = [
        "ap-southeast-2a",
        "ap-southeast-2b",
        "ap-southeast-2c"
      ]
      private_subnets = [
        "10.1.0.0/24",
        "10.1.1.0/24",
        "10.1.2.0/24"
      ]
      public_subnets = [
        "10.1.3.0/24",
        "10.1.4.0/24",
        "10.1.5.0/24"
      ]
    }
  }
}

module "region-us-east-1" {
  source = "./modules/region"

  name            = local.regions["us-east-1"]["name"]
  cidr            = local.regions["us-east-1"]["cidr"]
  azs             = local.regions["us-east-1"]["azs"]
  public_subnets  = local.regions["us-east-1"]["public_subnets"]
  private_subnets = local.regions["us-east-1"]["private_subnets"]

  providers = {
    aws = aws.us-east-1
  }
}

module "region-ap-southeast-2" {
  source = "./modules/region"

  name            = local.regions["ap-southeast-2"]["name"]
  cidr            = local.regions["ap-southeast-2"]["cidr"]
  azs             = local.regions["ap-southeast-2"]["azs"]
  public_subnets  = local.regions["ap-southeast-2"]["public_subnets"]
  private_subnets = local.regions["ap-southeast-2"]["private_subnets"]

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "global_accelerator" {
  source  = "terraform-aws-modules/global-accelerator/aws"
  version = "3.0.0"

  name = local.name

  listeners = {
    http = {
      client_affinity = "SOURCE_IP"

      endpoint_groups = {
        "us-east-1" = {
          health_check_port             = 80
          health_check_protocol         = "HTTP"
          health_check_path             = "/"
          health_check_interval_seconds = 10
          health_check_timeout_seconds  = 5
          healthy_threshold_count       = 2
          unhealthy_threshold_count     = 2
          traffic_dial_percentage       = 100

          endpoint_configuration = [{
            client_ip_preservation_enabled = true
            endpoint_id                    = module.region-us-east-1["alb_arn"]
            weight                         = 100
          }]
        },
        "ap-southeast-2" = {
          endpoint_group_region         = "ap-southeast-2"
          health_check_port             = 80
          health_check_protocol         = "HTTP"
          health_check_path             = "/"
          health_check_interval_seconds = 10
          health_check_timeout_seconds  = 5
          healthy_threshold_count       = 2
          unhealthy_threshold_count     = 2
          traffic_dial_percentage       = 100

          endpoint_configuration = [{
            client_ip_preservation_enabled = true
            endpoint_id                    = module.region-ap-southeast-2["alb_arn"]
            weight                         = 100
          }]
        }
      }

      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    }
  }

  listeners_timeouts = {
    create = "35m"
    update = "35m"
    delete = "35m"
  }

  endpoint_groups_timeouts = {
    create = "35m"
    update = "35m"
    delete = "35m"
  }
}
