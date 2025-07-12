# CloudVPN-Misroute

## Scenario: VPN Misconfiguration with VPC Peering and Metadata Exploitation

This CloudGoat scenario demonstrates how an attacker can abuse a misconfigured AWS Client VPN endpoint to pivot into a private VPC, and then laterally move into a peered VPC. There, the attacker exploits EC2 metadata exposure to gain elevated IAM privileges and access sensitive data in an S3 bucket.

---

## Attack Narrative

1. **VPN Credentials Leak**  
   The attacker obtains `.ovpn` and credential files, allowing VPN access to *VPC-A*.

2. **Internal Reconnaissance**  
   After VPN connection, the attacker performs internal scanning inside *VPC-A*. Nothing valuable is found.

3. **VPC Peering Discovery**  
   The attacker discovers that *VPC-A* is peered with another VPC (*VPC-B*), and can reach certain internal resources.

4. **Pivot to Peered VPC**  
   Using misconfigured security group rules, the attacker pivots into *VPC-B*.

5. **EC2 Metadata Exploitation**  
   In *VPC-B*, the attacker accesses an EC2 instance with a role that grants read access to a restricted S3 bucket.

6. **Sensitive Data Exfiltration**  
   Using the IAM role credentials, the attacker downloads `flag.txt` from the private S3 bucket.

---

## Learning Objectives

- Understand the risks of weak VPN access control.
- Discover how VPC Peering can lead to lateral movement if not properly restricted.
- Learn to secure EC2 instance metadata and IAM roles.
- Explore S3 bucket permissions and isolation techniques.

---

## Scenario Setup

| Resource     | Description |
|--------------|-------------|
| VPC-A        | Entry point via VPN |
| VPC-B        | Target network with exploitable EC2 |
| EC2 Instances| Used for pivot and metadata access |
| VPN Endpoint | Misconfigured access via leaked credentials |
| S3 Bucket    | Stores the flag, restricted by IAM policy |
| VPC Peering  | Connects VPC-A and VPC-B |

---

## Files Provided

- `client.ovpn` – Dummy OpenVPN config
- `credentials.txt` – VPN username and password

---

## Completion Criteria

✅ Successful download of `flag.txt` from the private S3 bucket  
✅ Demonstration of VPC Peering abuse and metadata exploitation

---

## Cleanup

To destroy the environment:

```bash
cloudgoat destroy CloudVPN-Misroute
