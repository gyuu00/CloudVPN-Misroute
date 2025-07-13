from core.base.scenario import Scenario

class cloudvpnmisroute(Scenario):

    name = "cloudvpnmisroute"

    @staticmethod
    def summary():
        return (
            "Leaked VPN credentials allow an attacker to access VPC-A via a misconfigured AWS Client VPN. "
            "From there, they discover a peered VPC (VPC-B) and pivot into it via misconfigured security group rules. "
            "Inside VPC-B, the attacker exploits EC2 instance metadata to gain IAM credentials and download sensitive data from a private S3 bucket."
        )

    def start(self):
        return (
            "You’ve discovered a leaked set of VPN credentials and configuration files.\n"
            "They appear to grant access to an AWS environment via a Client VPN endpoint.\n"
            "Your mission is to explore the internal network and exfiltrate sensitive data, if possible.\n"
        )

    def finish(self):
        return (
            "You’ve successfully obtained IAM credentials from the EC2 metadata service in VPC-B, "
            "and used them to download the flag from a private S3 bucket.\n"
            "This illustrates the risk of combining VPN misconfigurations, overly permissive VPC peering, "
            "and EC2 metadata exposure."
        )

    def create(self):
        return {
            "command": "terraform init && terraform apply --auto-approve",
            "cwd": "scenarios/cloudvpnmisroute/terraform"
        }

    def destroy(self):
        return {
            "command": "terraform destroy --auto-approve",
            "cwd": "scenarios/cloudvpnmisroute/terraform"
        }
