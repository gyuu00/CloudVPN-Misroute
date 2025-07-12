output "vpn_credentials_file_url" {
  description = "URL to the leaked VPN credentials"
  value       = "https://${aws_s3_bucket.leak_bucket.bucket}.s3.amazonaws.com/credentials.txt"
}

output "vpn_config_file_url" {
  description = "URL to the leaked VPN configuration file"
  value       = "https://${aws_s3_bucket.leak_bucket.bucket}.s3.amazonaws.com/client.ovpn"
}

output "ec2_b_private_ip" {
  description = "Private IP of EC2 instance in VPC-B (target instance)"
  value       = aws_instance.ec2_b.private_ip
}

output "s3_bucket_with_flag" {
  description = "Name of the S3 bucket that contains the flag"
  value       = aws_s3_bucket.leak_bucket.id
}
