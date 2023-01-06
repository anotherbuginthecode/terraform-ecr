
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  project_family = "demoecr"
  repositories = {
    "nginx" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 7
      environment           = "dev"
      tags = {
        Project     = "ECRDemo"
        Owner       = "anotherbuginthecode"
        Purpose     = "Reverse Proxy"
        Description = "NGINX docker image"
      }
    }

    "frontend" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 3
      environment           = "dev"
      tags = {
        Project     = "ECRDemo"
        Owner       = "anotherbuginthecode"
        Purpose     = "Frontend"
        Description = "Frontend docker image using ReactJS"
      }
    }

    "backend" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      environment           = "dev"
      expiration_after_days = 0 # no expiration policy set
      tags = {
        Project     = "ECRDemo"
        Owner       = "anotherbuginthecode"
        Purpose     = "Backend"
        Description = "Backend docker image using Python Flask"
      }
    }
  }
}

# single ecr
# module "ecr" {
#   source = "./modules/ecr"

#   name                  = "nginx"
#   project_family        = "demoecr"
#   environment           = "dev"
#   image_tag_mutability  = "IMMUTABLE"
#   scan_on_push          = true
#   expiration_after_days = 7
#   additional_tags = {
#     Project     = "ECRDemo"
#     Owner       = "anotherbuginthecode"
#     Purpose     = "Reverse Proxy"
#     Description = "NGINX docker image"
#   }
# }


# multiple ecr
module "ecr" {
  source   = "./modules/ecr"
  for_each = local.repositories

  name                  = each.key
  project_family        = local.project_family
  environment           = each.value.environment
  image_tag_mutability  = each.value.image_tag_mutability
  scan_on_push          = each.value.scan_on_push
  expiration_after_days = each.value.expiration_after_days
  additional_tags       = each.value.tags

}