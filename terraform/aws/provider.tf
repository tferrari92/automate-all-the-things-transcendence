terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }

  backend "s3" {
    bucket         = "gonchi-tf-state-bucket"          # This value was modified by the initial-setup python script
    dynamodb_table = "gonchi-tf-state-dynamo-db-table" # This value was modified by the initial-setup python script
    key            = "terraform.tfstate"
    region         = "us-east-1" # This value was modified by the initial-setup python script
    encrypt        = true
  }
}



# ----------------- AWS -----------------

provider "aws" {
  # region = var.region
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}



# ----------------- Helm -----------------

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.cluster.id
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)

    token = data.aws_eks_cluster_auth.default.token
  }
}
