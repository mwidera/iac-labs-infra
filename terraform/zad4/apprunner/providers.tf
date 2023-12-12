terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.24.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.24.0"
    }
  }
}

  access_key                  = "mock_access_key"  s3_use_path_style           = true  secret_key                  = "mock_secret_key"  skip_credentials_validation = true  skip_metadata_api_check     = true  skip_requesting_account_id  = true  endpoints {    ec2 = "http://localhost:4566"  }  region = "eu-central-1"
}