variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair (for SSH access from Ansible)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Restrict SSH to your own IP in production, e.g. 1.2.3.4/32"
  default     = "0.0.0.0/0"
}
