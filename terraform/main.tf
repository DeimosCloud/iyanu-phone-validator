#-------------------------
#   VPC
#-------------------------


locals {

  common_labels = {

    environment = var.environment
    managed_by  = "terraform"
  }

}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs              = var.availability_zones
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.common_labels
}

#-------------------------
  #Security Group
#-------------------------

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  name        = "PostgreSQL-SG"
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
       description = "PostgreSQL access from within VPC"
       from_port   = 5432
       to_port     = 5432
       protocol    = "tcp"
       cidr_blocks = "0.0.0.0/0"
    },
   
  ]
  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
}

#   tags = local.common_labels
# }


module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "Loabalancer-SG"
  description = "loadbalancer security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  tags = local.common_labels
}


# ********** Application SG**********
module "application_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "Application-SG"
  description = "Complete microservice security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
   
    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]

  tags = local.common_labels
}

#-------------------------
#   Ansible master SG
#-------------------------
module "ansible_controller_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "Ansible-SG"
  description = "ansible master security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow Port 1337"
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
     {
      description = "Allow HTTPS"
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Deny all outgoing traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  tags = local.common_labels
}


#For SERVERS

#-------------------------
  #Servers
#-------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.load_balancer

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "lb-jumia-phone-validator"
  monitoring             = true
  vpc_security_group_ids = [module.lb_security_group.security_group_id]
  subnet_id              =  module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install nginx -y
              sudo service nginx start
              sudo chkconfig nginx on
              sudo yum update -y
              sudo yum install python3-pip -y

              sudo sed -i 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
              sudo service sshd restart
              EOF


 tags = merge (
    local.common_labels,
    {
      Name = "load_balancer"
    }
 )
}

#-------------------------
#   Application Servers
#-------------------------

module "Application" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.microservice

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "application-jumia-phone-validator"
  monitoring             = true
  vpc_security_group_ids = [module.application_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              sudo yum update -y
              sudo yum install python3-pip -y

            
              sudo sed -i 's/#Port 22/Port 1337/' /etc/ssh/sshd_config
              sudo service sshd restart
              EOF

  tags = merge (
    local.common_labels,
    {
      Name = "microservice"
    }
  )
}


module "ansible_controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.ansible_master

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "ansible-controller"
  monitoring             = true
  vpc_security_group_ids = [module.ansible_controller_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[1]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install python3-pip -y
              python3 -m pip install
              sudo apt update 
              sudo apt-add-repository -y ppa:ansible/ansible
              sudo apt-get update
              sudo apt-get install ansible
              EOF

  tags = merge (
    local.common_labels,
    {
      Name = "master-node"
    }
  )
}


#-------------------------
#   POSGRES Database
#-------------------------

resource "aws_db_instance" "postgres_db" {
  allocated_storage             = var.db_allocated_storage
  db_name                       = var.db_name
  engine                        = var.db_engine
  engine_version                = var.db_engine_version
  instance_class                = var.db_instance_class
  username                      = var.db_username
  multi_az                      = true
  parameter_group_name          = aws_db_parameter_group.postgres_db.name
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.db_secret.key_id
  db_subnet_group_name          = module.vpc.database_subnet_group
  skip_final_snapshot           = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_db_parameter_group" "postgres_db" {
  name   = "postgres-db-pg"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "aws_kms_key" "db_secret" {
  description             = "KMS key for postgres RDS"
  deletion_window_in_days = 10
  tags                    = local.common_labels
}