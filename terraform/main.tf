# create the VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
  enable_dns_support   = var.dnsSupport 
  enable_dns_hostnames = var.dnsHostNames
tags = {
    Name = "Prod VPC"
}
} 
# create the Subnet
resource "aws_subnet" "prod_subnet" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone
tags = {
   Name = "Prod Subnet"
}
} 
# Create the Security Group
resource "aws_security_group" "prod_security_group" {
  vpc_id       = aws_vpc.prod_vpc.id
  name         = "Prod Security Group"
  description  = "Prod Security Group"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "Prod Security Group"
   Description = "Prod Security Group"
}
} 
# create VPC Network access control list
resource "aws_network_acl" "prod_security_acl" {
  vpc_id = aws_vpc.prod_vpc.id
  subnet_ids = [ aws_subnet.prod_subnet.id ]
# allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 80
    to_port    = 80
  }
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22 
    to_port    = 22
  }
  
  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80  
    to_port    = 80 
  }
 
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
tags = {
    Name = "Prod ACL"
}
} 
# Create the Internet Gateway
resource "aws_internet_gateway" "prod_gw" {
 vpc_id = aws_vpc.prod_vpc.id
 tags = {
        Name = "Prod Internet Gateway"
}
} 
# Create the Route Table
resource "aws_route_table" "prod_route_table" {
 vpc_id = aws_vpc.prod_vpc.id
 tags = {
        Name = "Prod Route Table"
}
} 
# Create the Internet Access
resource "aws_route" "Prod_internet_access" {
  route_table_id         = aws_route_table.prod_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.prod_gw.id
} 
# Associate the Route Table with the Subnet
resource "aws_route_table_association" "prod_association" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_route_table.id
} 


#To create private key for ec2 instance

resource "tls_private_key" "ec2_key" {
 algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
 key_name = "ec2_key"
 public_key = "${tls_private_key.ec2_key.public_key_openssh}"
 depends_on = [
  tls_private_key.ec2_key
 ]
}
resource "local_file" "key" {
 content = "${tls_private_key.ec2_key.private_key_pem}"
 filename = "ec2_key.pem"
 file_permission ="0400"
 depends_on = [
  tls_private_key.ec2_key
 ]
}

#For VMS
resource "aws_instance" "Application" {
 ami = "ami-0f61de2873e29e866"
 instance_type = "t2.micro"
 key_name = "${aws_key_pair.generated_key.key_name}"
 vpc_security_group_ids = [ "${ aws_security_group.prod_security_group.id}" ]
 subnet_id = "${aws_subnet.prod_subnet.id}"
 
 tags = {
  Name = "<Microservice_instance_name>"
 }
}