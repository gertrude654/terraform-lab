# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_microservice_role"

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

# IAM policy attachment for the role (e.g., allowing S3 access)
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Security group
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
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
}

# EC2 instance
resource "aws_instance" "microservice" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example AMI (replace with actual one)
  instance_type = "t2.micro"
  key_name      = "your-ssh-key"           # Make sure you have the key

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  security_groups = [aws_security_group.allow_http.name]

  tags = {
    Name = "Microservice-Instance"
  }
}

# Attach IAM role to EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
