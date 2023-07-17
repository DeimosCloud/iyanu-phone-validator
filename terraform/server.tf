#-------------------------
#   Servers
#-------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.load_balancer

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "loadbalancer"
  monitoring             = true
  vpc_security_group_ids = [module.lb_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install nginx -y
              sudo service nginx start
              sudo chkconfig nginx on

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
#   Servers
#-------------------------

module "Application" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.microservice

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "microservice"
  monitoring             = true
  vpc_security_group_ids = [module.application_security_group.security_group_id]
  subnet_id              = module.vpc.private_subnets[1]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on

            
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


module "ansible_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.ansible_master

  ami                    = var.linux_ami
  instance_type          = var.linux_instance_type
  key_name               = "ansible_master"
  monitoring             = true
  vpc_security_group_ids = [module.ansible_master_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[1]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install python3-pip -y
              python3 -m pip install 
              EOF

  tags = merge (
    local.common_labels,
    {
      Name = "master-node"
    }
  )
}

#----------------------------

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ssm_role.name
}