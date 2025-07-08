from core.scenario import Scenario
from core.utils import get_public_ip

class CloudvpnMisroute(Scenario):
    def generate(self):
        """
        Deploys the scenario using Terraform.
        Creates:
        - Public S3 bucket with leaked VPN config
        - AWS Client VPN Endpoint
        - EC2 instances (admin-server)
        - S3 bucket with flag
        - Security group allowing VPN-only SSH access
        """
        self.run_terraform_apply()

    def start(self):
        """
        Provides initial scenario instructions to the user.
        """
        print("\n[💡] Scenario: CloudVPN-misroute")
        print("================================================================================")
        print("[*] A misconfigured AWS Client VPN has leaked its configuration in a public S3 bucket.")
        print("[*] Your mission is to:")
        print("    1. Retrieve the VPN configuration from the public S3 bucket.")
        print("    2. Connect to the VPN and access the internal VPC.")
        print("    3. Locate the internal admin-server and access it via SSH.")
        print("    4. Extract IAM credentials from the EC2 metadata service.")
        print("    5. Use the credentials to download a flag from a private S3 bucket.")
        print("================================================================================\n")

    def exploit(self):
        """
        (Optional) Step-by-step manual attack guidance.
        """
        print("\n[🚩] Exploit Instructions:")
        print("================================================================================")
        print("[1] Find and download leaked VPN config from the public S3 bucket.")
        print("[2] Use the `.ovpn` and `credentials.txt` to connect to the AWS VPN endpoint.")
        print("[3] Once inside, scan the VPC network to find the admin-server (hint: 10.0.1.X).")
        print("[4] SSH into the server (you are allowed by SG via VPN IP).")
        print("[5] Run:")
        print("       curl http://169.254.169.254/latest/meta-data/iam/security-credentials/")
        print("       curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>")
        print("[6] Use the keys to:")
        print("       aws s3 cp s3://cg-secret-flag/flag.txt . --region <region>")
        print("[7] Done!")
        print("================================================================================\n")

    def destroy(self):
        """
        Destroys the scenario and all deployed resources.
        """
        self.run_terraform_destroy()
