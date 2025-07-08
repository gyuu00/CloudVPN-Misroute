provider "aws" {
  region = var.region
}

# === 1. 공개 S3 버킷 (VPN 설정 유출용)
resource "aws_s3_bucket" "leaked_vpn_bucket" {
  bucket = "cg-cloudvpn-misroute-public"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "vpn_config" {
  bucket = aws_s3_bucket.leaked_vpn_bucket.bucket
  key    = "client.ovpn"
  source = "${path.module}/files/client.ovpn"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "credentials" {
  bucket = aws_s3_bucket.leaked_vpn_bucket.bucket
  key    = "credentials.txt"
  source = "${path.module}/files/credentials.txt"
  acl    = "public-read"
}

# === 2. 비공개 S3 버킷 (플래그 저장)
resource "aws_s3_bucket" "secret_flag_bucket" {
  bucket = "cg-cloudvpn-flag"
  force_destroy = true
}

resource "aws_s3_bucket_object" "flag" {
  bucket = aws_s3_bucket.secret_flag_bucket.bucket
  key    = "flag.txt"
  content = "flag{you_got_it_from_s3}"
}

# === 3. IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "cg-cloudvpn-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "s3_read_only" {
  name = "cg-cloudvpn-s3-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Effect   = "Allow"
      Resource = [
        "${aws_s3_bucket.secret_flag_bucket.arn}",
        "${aws_s3_bucket.secret_flag_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "cg-cloudvpn-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# === 4. EC2 인스턴스
resource "aws_instance" "admin_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = "subnet-REPLACE"       # VPN에 연결된 VPC의 subnet ID로 수정 필요
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  key_name      = "REPLACE_WITH_KEYPAIR"

  tags = {
    Name = "cg-admin-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "flag{you_got_it_from_s3}" > /home/ec2-user/flag.txt
              EOF
}
