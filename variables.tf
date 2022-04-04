/********
variables
*********/

# EC2 Instance related variables

variable "ec2_region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ec2_image" {
  default = "ami-04505e74c0741db8d"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_keypair" {
  default = "deven-key"
}

variable "ec2_tags" {
  default = "apache-web-server"
}


# VPC related variables
variable "vpc_cidr" {
  description = "The CIDR Block for the SiteSeer VPC"
  default     = "10.150.150.0/24"
}

variable "to_internet_ipv4" {
  description = "Route in the SiteSeer Route Table"
  default     = "0.0.0.0/0"
}

variable "to_internet_ipv6" {
  description = "Route in the SiteSeer Route Table"
  default     = "::/0"
}

variable "subnet_cidr" {
  description = "Private Subnet CIDR Block"
  default     = "10.150.150.0/28"
}

variable "private_ip" {
  description = "Private IP from the Subnet CIDR Block"
  default     = "10.150.150.10"
}



