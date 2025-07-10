variable "region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "vpn_username" {
  description = "Username for VPN authentication"
  default     = "cguser"
}

variable "vpn_password" {
  description = "Password for VPN authentication"
  default     = "cgpassword123"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0c94855ba95c71c99" # Amazon Linux 2 (us-east-1)
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "bucket_name_flag" {
  description = "Name of the private S3 bucket storing the flag"
  default     = "cg-secret-flag"
}

variable "bucket_name_public" {
  description = "Name of the public S3 bucket containing VPN files"
  default     = "cg-vpn-public-bucket"
}
