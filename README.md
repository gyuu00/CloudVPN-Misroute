# CloudVPN-misroute

## Summary

In this scenario, an attacker leverages leaked VPN credentials to access a private AWS VPC. From inside the network, the attacker pivots into an EC2 instance, extracts IAM credentials, and bypasses conditional IAM and S3 bucket policies by staying within the allowed network path, ultimately exfiltrating a protected flag from a private S3 bucket.

---

## Cloud Concepts Covered

- AWS Client VPN
- Public S3 bucket misconfiguration
- Security group bypass via internal network
- EC2 metadata service abuse
- IAM credential compromise
- IAM conditional policy (aws:sourceVpce)
- VPC endpoint-based S3 access restriction

---

## Scenario Flow

1. An S3 bucket containing a `.ovpn` configuration file and `credentials.txt` is publicly exposed.
2. The attacker uses these files to connect to an AWS Client VPN endpoint.
3. Once inside the VPN, the attacker scans the network and discovers an EC2 instance.
4. The attacker connects to the EC2 instance via SSH (allowed only from internal VPN clients).
5. Using the EC2 metadata service, the attacker retrieves IAM credentials assigned to the instance.
6. The attacker attempts to access a private S3 bucket using the stolen credentials but is denied.
7. After inspecting the policies, the attacker realizes access is restricted to a specific VPC endpoint.
8. By maintaining VPN connectivity (i.e., staying in-network), the attacker retries the S3 access and successfully retrieves `flag.txt`.

---

## Goal

Download `flag.txt` from the private S3 bucket by meeting all security conditions using the compromised IAM credentials.

---

## Difficulty

🟧 Medium

---

## Detection & Prevention

- Monitor public S3 buckets for sensitive configuration files such as `.ovpn` or credential stores.
- Restrict access to EC2 metadata using IMDSv2 and firewall rules.
- Use conditional IAM policies in combination with VPC endpoints to limit credential abuse.
- Enable logging for VPN connections, S3 access, and EC2 metadata usage.

---

## Tags

`vpn`, `s3`, `iam`, `metadata`, `vpc-endpoint`, `cloud`, `security-group`, `aws`

