provider "aws" {
  region = var.region
}

# VPC-A (VPN 연결 대상)
resource "aws_vpc" "vpc_a" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "${var.project_prefix}-vpc-a"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_security_group" "sg_a" {
  name        = "${var.project_prefix}-sg-a"
  description = "Allow internal SSH"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_a" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg_a.id]
  key_name               = "cloudgoat-key"

  tags = {
    Name = "${var.project_prefix}-ec2-a"
  }
}

# VPC-B (피어링 대상)
resource "aws_vpc" "vpc_b" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "${var.project_prefix}-vpc-b"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_security_group" "sg_b" {
  name        = "${var.project_prefix}-sg-b"
  description = "Allow SSH from VPC-A"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_b" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.sg_b.id]
  key_name               = "cloudgoat-key"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "${var.project_prefix}-ec2-b"
  }
}

# VPC Peering 연결
resource "aws_vpc_peering_connection" "peering" {
  vpc_id        = aws_vpc.vpc_a.id
  peer_vpc_id   = aws_vpc.vpc_b.id
  auto_accept   = true

  tags = {
    Name = "${var.project_prefix}-peering"
  }
}

resource "aws_route" "route_a_to_b" {
  route_table_id             = aws_vpc.vpc_a.default_route_table_id
  destination_cidr_block     = aws_vpc.vpc_b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "route_b_to_a" {
  route_table_id             = aws_vpc.vpc_b.default_route_table_id
  destination_cidr_block     = aws_vpc.vpc_a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

# S3 Bucket - Leaked VPN Config
resource "aws_s3_bucket" "leak_bucket" {
  bucket = "${var.project_prefix}-vpn-config"
}

resource "aws_s3_bucket_object" "credentials_file" {
  bucket       = aws_s3_bucket.leak_bucket.id
  key          = "credentials.txt"
  source       = "${path.module}/files/credentials.txt"
  content_type = "text/plain"
}

resource "aws_s3_bucket_object" "ovpn_file" {
  bucket       = aws_s3_bucket.leak_bucket.id
  key          = "client.ovpn"
  source       = "${path.module}/files/client.ovpn"
  content_type = "text/plain"
}

resource "aws_s3_bucket_object" "flag" {
  bucket       = aws_s3_bucket.leak_bucket.id
  key          = "flag.txt"
  content      = "FLAG-THIS-IS-YOUR-TREASURE"
  content_type = "text/plain"
}

# IAM Policy and Role for EC2 to access S3
resource "aws_iam_policy" "s3_read_policy" {
  name        = "${var.project_prefix}-s3-read"
  description = "Allows read access to specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.leak_bucket.arn}",
          "${aws_s3_bucket.leak_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_prefix}-profile"
  role = aws_iam_role.ec2_role.name
}
