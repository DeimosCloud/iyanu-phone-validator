# iyanu-phone-validator

# Prerequisites
## AWS account with IAM credentials

- AWS CLI

- Terraform

- Ansible

- Docker

# Configure AWS CLI to connect to AWS account
- Connect with an AWS user
- CLI Access through Access key ID and Secret Access key

# For this task i used configure AWS ACCESS with CLI Access through Access key ID and Secret Access key

- aws configure

- AWS Access Key ID : (which is given in the IAM users section)

- AWS Secret Access Key : (which is given in the IAM users section)

- Default region name : (set your preferred region, for ex: ap-south-1)

- Default output format : (ser your preferred output format, for ex: json)

- Configuration is automatically stored in your home directory under /.aws

# For Iac I used terraform and ansible as the Configuration management

## Overview

- Create an AWS EC2 Instance with Terraform

- Configure Inventory file to connect to AWS EC2 Instance

- Install Docker and docker-compose

- Copy docker-compose file to the server

