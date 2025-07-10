provider "aws" {
  region = var.region
}

# ----------------------
# VPC + Subnet
# ----------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudvpn-misroute-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudvpn-misroute-subnet"
  }
}

# ----------------------
# Internet Gateway + Route Table
# ----------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudvpn-misroute-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "cloudvpn-misroute-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# ----------------------
# Security Group: allow SSH from VPN clients only
# ----------------------

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-vpn-only-sg"
  description = "Allow SSH from VPN clients only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]  # 내부 VPN 대역에서만 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-vpn-only-sg"
  }
}

# ----------------------
# IAM Role + Instance Profile (with VPCE condition)
# ----------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "cloudvpn-misroute-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name   = "ec2-s3-limited-policy"
  role   = aws_iam_role.ec2_role.id
  policy = templatefile("${path.module}/iam_policy.json", {
    vpce_id = aws_vpc_endpoint.s3.id
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloudvpn-misroute-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ----------------------
# EC2 Instance (admin-server)
# ----------------------

resource "aws_instance" "admin_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  key_name                    = "h4q" # 사용 중인 키페어로 수정하거나 제거

  tags = {
    Name = "admin-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "flag{this-is-your-secret}" > /home/ec2-user/flag.txt
              chown ec2-user:ec2-user /home/ec2-user/flag.txt
              EOF
}


# ----------------------
# Public S3 Bucket (leaked VPN config)
# ----------------------

resource "aws_s3_bucket" "public_vpn" {
  bucket = var.bucket_name_public

  tags = {
    Name = "cg-vpn-public-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "vpn_block" {
  bucket = aws_s3_bucket.public_vpn.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.public_vpn.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "arn:aws:s3:::${var.bucket_name_public}/*"
    }]
  })
}

resource "aws_s3_bucket_object" "client_ovpn" {
  bucket = aws_s3_bucket.public_vpn.id
  key    = "client.ovpn"
  source = "${path.module}/files/client.ovpn"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "credentials_txt" {
  bucket = aws_s3_bucket.public_vpn.id
  key    = "credentials.txt"
  source = "${path.module}/files/credentials.txt"
  acl    = "public-read"
}

# ----------------------
# Private S3 Bucket (holds flag.txt)
# ----------------------

resource "aws_s3_bucket" "private_flag" {
  bucket = var.bucket_name_flag

  tags = {
    Name = "cg-secret-flag"
  }
}

resource "aws_s3_bucket_policy" "private_flag_policy" {
  bucket = aws_s3_bucket.private_flag.id

  policy = templatefile("${path.module}/s3_bucket_policy.json", {
    vpce_id = aws_vpc_endpoint.s3.id
  })
}

resource "aws_s3_bucket_object" "flag_file" {
  bucket = aws_s3_bucket.private_flag.id
  key    = "flag.txt"
  content = "flag{this-is-your-secret}"
  acl    = "private"
}


# ----------------------
# VPC Endpoint for S3
# ----------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.public.id]
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "cloudvpn-misroute-s3-vpce"
  }
}

