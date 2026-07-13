terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "duoc_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "DUOC-VPC"
  }
}

resource "aws_subnet" "duoc_subnet" {
  vpc_id                  = aws_vpc.duoc_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "DUOC-Subnet"
  }
}

resource "aws_security_group" "duoc_sg" {
  vpc_id = aws_vpc.duoc_vpc.id
  name   = "DUOC-SG"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DUOC-SG"
  }
}

resource "aws_instance" "duoc_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 20.04 en us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.duoc_subnet.id
  vpc_security_group_ids = [aws_security_group.duoc_sg.id]

  tags = {
    Name = "DUOC-EC2"
  }
}
