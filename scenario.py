from core.base.scenario import Scenario

class CloudVPNMisroute(Scenario):
    @staticmethod
    def summary():
        return "Leaked VPN credentials allow a user to pivot into a private AWS network, compromise EC2 IAM credentials, and access a restricted S3 bucket via a VPC endpoint."

    def start(self):
        return (
            "An S3 bucket has been found containing what appear to be VPN configuration files.\n"
            "Your objective is to gain access to the internal network, identify and exploit further misconfigurations, and retrieve a flag from a private S3 bucket."
        )

    def exploit(self):
        return (
            "1. Discover the leaked `client.ovpn` and `credentials.txt` in the public S3 bucket.\n"
            "2. Use the OpenVPN configuration to connect to the AWS VPN endpoint.\n"
            "3. Once inside the private network, scan for internal resources and locate the EC2 instance.\n"
            "4. SSH into the EC2 instance using internal access (security group allows VPN source).\n"
            "5. Use the EC2 metadata service to extract temporary IAM credentials.\n"
            "6. Attempt to access the S3 bucket with the credentials, receive an `AccessDenied` error.\n"
            "7. Realize that the IAM and bucket policies require access from a specific VPC endpoint.\n"
            "8. While staying connected to the VPN (within the VPC), retry the S3 access.\n"
            "9. Successfully retrieve the `flag.txt` file."
        )

    def finish(self):
        return (
            "You’ve successfully used a leaked VPN configuration to gain internal access,\n"
            "pivoted to an EC2 instance, bypassed IAM and S3 policy restrictions via a VPC endpoint,\n"
            "and exfiltrated a protected flag from a private S3 bucket."
        )
