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

# VPC con Flow Logs habilitados
resource "aws_vpc" "duoc_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "DUOC-VPC"
  }
}

resource "aws_flow_log" "duoc_vpc_flow" {
  vpc_id          = aws_vpc.duoc_vpc.id
  traffic_type    = "ALL"
  log_destination = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc/flowlogs"
}

# Subnet sin IP pública por defecto
resource "aws_subnet" "duoc_subnet" {
  vpc_id                  = aws_vpc.duoc_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "DUOC-Subnet"
  }
}

# Security Group con descripción a nivel de recurso y reglas
resource "aws_security_group" "duoc_sg" {
  vpc_id      = aws_vpc.duoc_vpc.id
  name        = "DUOC-SG"
  description = "Security group for DUOC lab"

  ingress {
    description = "Allow SSH from lab subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Allow HTTP from lab subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    description = "Allow outbound to lab subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }

  tags = {
    Name = "DUOC-SG"
  }
}

# Restringir el SG por defecto de la VPC
resource "aws_default_security_group" "duoc_default_sg" {
  vpc_id      = aws_vpc.duoc_vpc.id
  description = "Default SG restricted"

  ingress {
    description = "Block all ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  egress {
    description = "Block all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = {
    Name = "DUOC-Default-SG"
  }
}

# IAM Role simulado para EC2
resource "aws_iam_role" "duoc_ec2_role" {
  name               = "duoc-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Instancia EC2 con mejoras de seguridad
resource "aws_instance" "duoc_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 20.04 en us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.duoc_subnet.id
  vpc_security_group_ids = [aws_security_group.duoc_sg.id]
  iam_instance_profile   = aws_iam_role.duoc_ec2_role.name
  ebs_optimized          = true
  monitoring             = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "DUOC-EC2"
  }
}
