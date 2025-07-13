variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cloudgoat-vpn"
}

variable "vpn_username" {
  description = "VPN login username"
  type        = string
  default     = "admin"
}

variable "vpn_password" {
  description = "VPN login password"
  type        = string
  default     = "cloudgoat123"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}
