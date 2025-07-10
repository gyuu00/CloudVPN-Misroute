from core.base.scenario import Scenario as BaseScenario

class Scenario(BaseScenario):
    @staticmethod
    def summary():
        return "Leaked VPN credentials allow a user to pivot into a private AWS network, compromise EC2 IAM credentials, and access a restricted S3 bucket via a VPC endpoint."

    def start(self):
        return (
            "An S3 bucket has been found containing what appear to be VPN configuration files.\n"
            "Use the credentials to access the VPN and explore the internal network."
        )

    def finish(self):
        return (
            "The attacker successfully pivoted into the private cloud network, bypassed a restrictive security group,\n"
            "extracted IAM credentials from EC2 metadata, and accessed sensitive S3 data."
        )
