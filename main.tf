## First Initialize the terraform settings with the aws source, version, required version

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

# Then, initialize the aws providers with the aws platform access

provider "aws" {
  region     = var.ec2_region
  access_key = "ABCDEFGHIJKLMNOPQRST"
  secret_key = "YourSecretKey/CreateAndUpdateTheKeY"
}

# 1. Create VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "production"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-gw"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = var.to_internet_ipv4
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = var.to_internet_ipv6
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-route"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "prod-subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "subnet-1"
  }
}

# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod-subnet-1.id
  route_table_id = aws_route_table.prod-route.id
}

# 6. Create Security Group to allow port 22, 80, 443,
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web(http/s) inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.to_internet_ipv4]
  }

  ingress {
    description = "Http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.to_internet_ipv4]
  }

  ingress {
    description = "Https from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.to_internet_ipv4]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.to_internet_ipv4]
    ipv6_cidr_blocks = [var.to_internet_ipv6]
  }

  tags = {
    Name = "allow_web_ssh"
  }
}

# 7. Create a network interface with an IP in the subnet created in step 4
resource "aws_network_interface" "web-nic" {
  subnet_id       = aws_subnet.prod-subnet-1.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-nic.id
  associate_with_private_ip = var.private_ip
  depends_on                = [aws_internet_gateway.gw]
}


# 9. Create Ubuntu Server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami               = var.ec2_image
  instance_type     = var.ec2_instance_type
  availability_zone = var.availability_zone
  key_name          = var.ec2_keypair


  ## Associating this web-server-instance with the network interface we have created in step 7
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-nic.id
  }

  ## Volume size to be 20gib. AWS free tier provides upto 30Gib volume to use. By default, t2.micro instance is 8Gib.
  root_block_device {
    volume_size = 20
  }

  ## User data which helps to execute the command in the instance
  user_data = <<-EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
EOF

  tags = {
    Name = var.ec2_tags
  }

}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

output "server_private_ip" {
  value = aws_eip.one.private_ip
}

output "server_public_dns" {
  value = aws_eip.one.public_dns
}
