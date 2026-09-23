terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Networking ---
resource "aws_vpc" "lamp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "lamp-vpc" }
}

resource "aws_subnet" "lamp_subnet" {
  vpc_id                  = aws_vpc.lamp_vpc.id
  cidr_block               = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone        = "${var.aws_region}a"
  tags = { Name = "lamp-subnet" }
}

resource "aws_internet_gateway" "lamp_igw" {
  vpc_id = aws_vpc.lamp_vpc.id
}

resource "aws_route_table" "lamp_rt" {
  vpc_id = aws_vpc.lamp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lamp_igw.id
  }
}

resource "aws_route_table_association" "lamp_rta" {
  subnet_id      = aws_subnet.lamp_subnet.id
  route_table_id = aws_route_table.lamp_rt.id
}

# --- Security Group: HTTP/HTTPS in, SSH for Ansible ---
resource "aws_security_group" "lamp_sg" {
  name   = "lamp-sg"
  vpc_id = aws_vpc.lamp_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- IAM role for the instance (minimal example: CloudWatch logs) ---
resource "aws_iam_role" "lamp_role" {
  name = "lamp-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.lamp_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "lamp_profile" {
  name = "lamp-ec2-profile"
  role = aws_iam_role.lamp_role.name
}

# --- Latest Ubuntu 22.04 AMI ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- EC2 instance ---
resource "aws_instance" "lamp_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lamp_subnet.id
  vpc_security_group_ids = [aws_security_group.lamp_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.lamp_profile.name

  tags = { Name = "lamp-ec2" }
}
