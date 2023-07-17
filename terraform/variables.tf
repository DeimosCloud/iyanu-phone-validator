variable "availabilityZone" {
     default = "eu-west-3a"
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "subnetCIDRblock" {
    default = "10.0.1.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}

#==========
variable "region" {
  description = "The region for VPC"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment for VPC"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "The Availabilty zones for VPC "
  type        = list(string)
  default     = []
}

variable "vpc_cidr_block" {
  description = "The IP address range of the VPC in CIDR notation"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "The VPC name"
  type        = string
  default     = ""
}


variable "private_subnets" {
  description = "The IP address range of the VPC's Private address range in CIDR notation"
  type        = list(string) #set(string)
  default     = []
}


variable "public_subnets" {
  description = "The IP address range of the VPC's public address range in CIDR notation"
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Postgres database name"
  type        = string
}

variable "database_subnets" {
  description = "The IP address range of the VPC's database address range in CIDR notation"
  type        = list(string)
  default     = []
}

variable "linux_ami" {
  description = "ami for linux the instances"
  type        = string
  default     = ""
}

variable "linux_instance_type" {
  description = "Instance type for the ami"
  type        = string
  default     = ""
}

variable "load_balancer" {
  description = "name of the loadbalancer server"
  type        = string
  default     = ""
}

variable "microservice" {
  description = "name of the microservice server"
  type        = string
  default     = ""
}

variable "ansible_master" {
  description = "name of the ansible_master server"
  type        = string
  default     = ""
}
#-------------------------
#   Database Variables
#-------------------------
variable "db_engine" {
  description = "The database engine"
  type        = string
  default     = ""
}

variable "db_engine_version" {
  description = "The running version of the database"
  type        = string
  default     = ""
}

variable "db_major_engine_version" {
  description = "The optional version of the database"
  type        = string
  default     = ""
}

variable "db_family" {
  description = "The family the database belongs to"
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "The instance class of database"
  type        = string
  default     = ""
}

variable "db_allocated_storage" {
  description = "storage allocated to database"
  type        = number
  default     = null
}

variable "db_username" {
  description = "username for the database"
  type        = string
  default     = ""
}