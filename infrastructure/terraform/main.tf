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
  private_ip                 = "10.10.4.60"
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


#FOR AUTOMATION OF ANSIBLE WITH TERRAFORM
#for Ansible Dynamic Inventory Creation

# resource "null_resource" "loadbalancer" {

# 	triggers = {
# 		#mytest = timestamp()
# 	}

# 	provisioner "local-exec" {
# 	    command = "echo ${module.load_balancer.id} ansible_host=${module.load_balancer.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../ansible/keys/ansible/keys/lb-jumia-phone-validator.pem >> inventory"        
           
# 	  }
# }

# resource "null_resource" "application" {

# 	triggers = {
# 		#mytest = timestamp()
# 	}

# 	provisioner "local-exec" {
# 	    command = "echo ${module.Application.id} ansible_host=${module.Application.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../ansible/keys/application-jumia-phone-validator.pem >> inventory"
            
           
# 	  }
# }

# #Copy Dynamic inventory from local Workstation to the Ansible Server

# resource "null_resource" "dynamicinventory" {

# 	triggers = {
# 		# mytest = timestamp()
# 	}

# 	provisioner "local-exec" {
# 	    command = "scp -i ../ansible/keys/ansible-controller.pem inventory ubuntu@15.237.58.75:/tmp"
      
            
# 	  }
# 	depends_on = [ 
# 			null_resource.application , null_resource.loadbalancer
# 			]
# }

# #Login Remotely to the Ansible Server and and move the file to your own Custom Inventory location
#  resource "null_resource" "ssh3" {
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       host        = module.ansible_controller.public_ip
#       user        = "ubuntu"
#       private_key = file("../ansible/keys/ansible-controller.pem")
#     }

#     inline = [
#       # Remote-exec commands here
#               "sudo chmod 777 /tmp/inventory",
#               "sudo mv /tmp/inventory /etc/ansible/inventory",
#     ]
#   }

#   #To RUN PLAYBOOK
# 	# provisioner "local-exec" {
# 	#   command = "ansible-playbook  -i ${module.ansible_controller.public_ip}, --private-key ${file("../ansible/keys/ansible-controller.pem")} nginx.yaml"
              
# 	#   }

# # meta argument
# 	depends_on = [ 
# 			null_resource.application , null_resource.loadbalancer
# 			]
# }




