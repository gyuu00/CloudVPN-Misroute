# CloudVPN-Misroute

## Scenario: VPN Misconfiguration and Security Group Bypass

This scenario demonstrates how an attacker can exploit misconfigured AWS Client VPN and security group rules to pivot into a restricted internal network. Once inside, the attacker uses metadata exposure on an EC2 instance to steal IAM credentials and access sensitive data in S3.

---

## 🧭 Attack Flow

1. The attacker discovers a public S3 bucket containing leaked VPN configuration files (`client.ovpn`, `credentials.txt`).
2. Using the leaked credentials, the attacker connects to the AWS Client VPN endpoint and gains access to the internal VPC network.
3. Within the VPN, the attacker scans the internal IP range and identifies an `admin-server` instance that is **not accessible from the public internet**, but is open to VPN clients via security group rules.
4. The attacker uses SSH to log in to the `admin-server`.
5. From inside the EC2 instance, the attacker queries the **instance metadata service** at `169.254.169.254` and obtains temporary AWS credentials via the attached IAM Role.
6. These credentials are then used to access a **private S3 bucket**, where the attacker downloads the final `flag.txt`.

---

## 💡 What You'll Learn

- How VPN misconfiguration can lead to unintended internal access
- The importance of tightly scoped security group rules
- How IAM roles attached to EC2 instances can be abused via metadata
- Real-world example of privilege escalation within a cloud network

---

## ☁️ AWS Resources Used

- AWS Client VPN Endpoint
- S3 Bucket (public & private)
- EC2 Instances (`bastion`, `admin-server`)
- EC2 Security Groups (VPN-only SSH access)
- IAM Role with scoped S3 permissions
- Metadata Service (169.254.169.254)

---

## 🚩 Flag

The flag is stored in the private S3 bucket `cg-secret-flag/flag.txt`.  
To retrieve it, the attacker must access the EC2 instance via the VPN and use the instance role credentials.

---

## 🛡️ Detection & Prevention Tips

- Use MFA and strong authentication for VPN access
- Avoid exposing `.ovpn` or credential files in storage buckets
- Restrict EC2 IAM roles using least privilege principle
- Block access to the metadata service when not needed (IMDSv2)
- Monitor VPN usage and internal SSH activity

---

## ✅ Success Criteria

This scenario is complete when the attacker successfully downloads `flag.txt` from the `cg-secret-flag` S3 bucket using credentials obtained from the EC2 metadata service.
