terraform {
  cloud {
    organization = "auto-cv"
    workspaces {
      name = "auto-cv-pro"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}