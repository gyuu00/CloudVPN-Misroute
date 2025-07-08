output "vpn_s3_bucket" {
  value = aws_s3_bucket.leaked_vpn_bucket.bucket
  description = "Public S3 bucket containing VPN credentials"
}

output "secret_flag_bucket" {
  value = aws_s3_bucket.secret_flag_bucket.bucket
  description = "Private S3 bucket that contains the flag"
}

output "admin_server_private_ip" {
  value = aws_instance.admin_server.private_ip
  description = "IP address of the internal admin server"
}
