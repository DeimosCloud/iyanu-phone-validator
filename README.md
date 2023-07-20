# iyanu-phone-validator
# Deploy Reactjs and a Spring boot Java application on an EC2 Instance

# Prerequisites
## AWS account with IAM credentials

- AWS CLI

- Terraform

- Ansible

- Docker

# Configure AWS CLI to connect to AWS account
- Connect with an AWS user
- CLI Access through Access key ID and Secret Access key

 For this task i used configure AWS ACCESS with CLI Access through Access key ID and Secret Access key

- aws configure

- AWS Access Key ID : (which is given in the IAM users section)

- AWS Secret Access Key : (which is given in the IAM users section)

- Default region name : (set your preferred region, for ex: ap-south-1)

- Default output format : (ser your preferred output format, for ex: json)

- Configuration is automatically stored in your home directory under /.aws

# For Iac I used terraform and ansible as the Configuration management

## Overview

- Create an AWS EC2 Instance with Terraform

- Configure Inventory file using ansible to connect to AWS EC2 Instance

- Install Docker and docker-compose

- Copy docker-compose file to the server

## Create an AWS EC2 Instance with Terraform

- You can access the Terraform file [here](https://github.com/DeimosCloud/iyanu-phone-validator/tree/main/infrastructure/terraform)
- Create your own "terraform.tfvars" file and include the following:

```
region               = "eu-west-3"
environment          = "production"
vpc_cidr_block       = "10.10.0.0/16"
availability_zones   = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
vpc_name             = "Jumia_Phone_validator_vpc"
private_subnets      =  ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
public_subnets       =  ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
database_subnets     = ["10.10.8.0/24", "10.10.10.0/24"]
linux_ami            = "ami-05b5a865c3579bbc4"
linux_instance_type  = "t3.medium"
db_name              = "jumia_phone_validator_db"
db_engine_version    = "14.7"
db_engine            = "postgres"
db_instance_class    = "db.t3.large"
db_allocated_storage = 20
db_username          = "jumia"

```

Run `terraform init` (for initializing) and `terraform apply` to apply changes.

Ansible is being used for configuration management and for this challange i used ansible for severs configurations and installation of some packages.

