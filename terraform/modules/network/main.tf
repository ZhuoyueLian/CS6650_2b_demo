# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# List all subnets in that VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a security group to allow HTTP on both ALB (80) and container (8080)
resource "aws_security_group" "this" {
  name        = "${var.service_name}-sg"
  description = "Allow inbound on 80 and ${var.container_port}"
  vpc_id      = data.aws_vpc.default.id

  # Port 80 for ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic to ALB"
  }

  # Port 8080 for containers
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
    description = "Allow HTTP traffic to containers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}