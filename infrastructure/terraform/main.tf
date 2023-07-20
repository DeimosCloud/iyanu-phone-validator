#-------------------------
#   VPC
#-------------------------


locals {
  ssh_user        = "ubuntu"
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
     {
      description = "Allow HTTPS"
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      description = "Allow Port 8081"
      from_port   = 8081
      to_port     = 8081
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
      description = "Allow HTTP"
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

     {
      description = "Allow Port 8081"
      from_port   = 8081
      to_port     = 8081
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


# ********** Database SG**********
module "database_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "Database-SG"
  description = "Database security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTPS"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTP"
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

     {
      description = "Allow Port 5432"
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

  tags = local.common_labels
}

#For SERVERS

#-------------------------
  #Servers
#-------------------------

resource "aws_instance" "loadbalancer" {
  ami                         = var.linux_ami
  subnet_id                   = module.vpc.public_subnets[0]
  instance_type               = var.linux_instance_type
  associate_public_ip_address = true
  security_groups             = [module.lb_security_group.security_group_id]
  key_name                    = "lb-jumia-phone-validator"
  private_ip                 = "10.10.4.40"
  tags = merge (
    local.common_labels,
    {
      Name = "load_balancer"
    }
 )
}

resource "null_resource" "loadbalancer_server" {

  triggers = {
    time = timestamp()
  }

#Working ansible 
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      # private_key = file(local.loadbalancer_private_key_path)
      private_key = file("${path.module}./ansible/keys/lb-jumia-phone-validator.pem")
      host        = aws_instance.loadbalancer.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key=${path.module}./ansible/keys/lb-jumia-phone-validator.pem --ssh-common-args='-o StrictHostKeyChecking=no' lb.yaml -u ubuntu -i '${aws_instance.loadbalancer.public_ip},'"
    #command = "ansible-playbook --private-key=${path.module}./ansible/keys/lb-jumia-phone-validator.pem --ssh-common-args='-o StrictHostKeyChecking=no' ${path.module}./ansible/roles/firewall/tasks/main.yaml -u ubuntu -i '${aws_instance.loadbalancer.public_ip},'"

  }

}


#-------------------------
#   Application Servers
#-------------------------

resource "aws_instance" "application" {
  ami                         = var.linux_ami
  subnet_id                   = module.vpc.public_subnets[0]
  instance_type               = var.linux_instance_type
  associate_public_ip_address = true
  security_groups             = [module.application_security_group.security_group_id]
  key_name                    = "application-jumia-phone-validator"
  private_ip                 = "10.10.4.125"
  tags = merge (
    local.common_labels,
    {
      Name = "application"
    }
 )
}

#
resource "null_resource" "application_server" {

  triggers = {
    time = timestamp()
  }

#Working ansible 
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      # private_key = file(local.loadbalancer_private_key_path)
      private_key = file("${path.module}./ansible/keys/application-jumia-phone-validator.pem")
      host        = aws_instance.application.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key=${path.module}./ansible/keys/application-jumia-phone-validator.pem --ssh-common-args='-o StrictHostKeyChecking=no' servers.yaml -u ubuntu -i '${aws_instance.application.public_ip},'"
    
  }
}


###DATABASE

#======
#Ansible master

#=======
resource "aws_instance" "database" {
  ami                         = var.linux_ami
  subnet_id                   = module.vpc.public_subnets[0]
  instance_type               = var.linux_instance_type
  associate_public_ip_address = true
  security_groups             = [module.database_security_group.security_group_id]
  key_name                    = "database"
  private_ip                 = "10.10.4.167"
  tags = merge (
    local.common_labels,
    {
      Name = "Database"
    }
 )
}

resource "null_resource" "database_server" {

  triggers = {
    time = timestamp()
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("${path.module}./ansible/keys/database.pem")
      host        = aws_instance.database.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key=${path.module}./ansible/keys/database.pem --ssh-common-args='-o StrictHostKeyChecking=no' db.yaml -u ubuntu -i '${aws_instance.database.public_ip},'"
    
  }

}



#======
#Ansible master

#=======
resource "aws_instance" "ansible_master" {
  ami                         = var.linux_ami
  subnet_id                   = module.vpc.public_subnets[0]
  instance_type               = var.linux_instance_type
  associate_public_ip_address = true
  security_groups             = [module.lb_security_group.security_group_id]
  key_name                    = "ansible-controller"
  private_ip                 = "10.10.4.70"
  tags = merge (
    local.common_labels,
    {
      Name = "Ansible"
    }
 )
}

resource "null_resource" "ansible_server" {

  triggers = {
    time = timestamp()
  }

#Working ansible 
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("${path.module}./ansible/keys/ansible-controller.pem")
      host        = aws_instance.ansible_master.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key=${path.module}./ansible/keys/ansible-controller.pem --ssh-common-args='-o StrictHostKeyChecking=no' servers.yaml -u ubuntu -i '${aws_instance.ansible_master.public_ip},'"
    
  }

}







