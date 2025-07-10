output "public_s3_bucket_url" {
  description = "URL to the public S3 bucket containing the leaked VPN config"
  value       = "https://${aws_s3_bucket.public_vpn.bucket}.s3.amazonaws.com/"
}

output "vpn_credentials_file" {
  description = "Path to the credentials.txt file"
  value       = "https://${aws_s3_bucket.public_vpn.bucket}.s3.amazonaws.com/credentials.txt"
}

output "vpn_config_file" {
  description = "Path to the client.ovpn file"
  value       = "https://${aws_s3_bucket.public_vpn.bucket}.s3.amazonaws.com/client.ovpn"
}

output "admin_server_ip" {
  description = "EC2 public IP (reachable only via VPN)"
  value       = aws_instance.admin_server.public_ip
}

output "flag_bucket_name" {
  description = "Private S3 bucket containing the flag"
  value       = aws_s3_bucket.private_flag.bucket
}

output "vpc_endpoint_id" {
  description = "ID of the VPC Endpoint (used in IAM and S3 policies)"
  value       = aws_vpc_endpoint.s3.id
}
