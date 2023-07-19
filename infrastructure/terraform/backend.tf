terraform {
  backend "s3" {
    bucket  = "jumia-devops-challenge-terraform"
    key     = "remote/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}