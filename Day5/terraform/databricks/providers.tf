terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }
}

