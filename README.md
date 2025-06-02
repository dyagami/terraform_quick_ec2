# AWS quick EC2 Instance Setup with Terraform

A Terraform configuration to quickly spin up an AWS EC2 VM with SSH/RDP over-the-internet access. Ideal for temporary use cases like development or testing. Highly discouraged in production environments due to remote access ports being exposed by firewall directly to the internet.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed
- AWS account with [IAM credentials](https://www.youtube.com/watch?v=OZsmKaIz_M0)
- SSH public key for secure access

***

## Setup Instructions

1. **Prepare Your Environment**

2. **Clone this repository** ```git clone https://github.com/dyagami/terraform_quick_ec2.git```
  
3. **Create an IAM user and generate an Access Key with the following permissions:**
    - `AmazonEC2FullAccess`
    - `IAMReadOnlyAccess` (for Terraform to read IAM resources)

4. **Configure Variables**

   Edit `terraform.tfvars` file in your working directory with:

    ```
    admin_pubkey = "ssh-XXXX (full SSH public key line with user and host)"
    aws_access_key = "YOUR_ACCESS_KEY"
    aws_secret_key = "YOUR_SECRET_KEY"
    aws_instance_type = "t3.micro"                   # Adjust as needed
    aws_region = "us-east-1"                # Adjust as needed
    ```

5. **Run Terraform Commands**

    ```
    terraform init
    terraform plan

    # var.os
    #  Enter OS name - use at least 2 words separated by spaces to avoid mismatch
    #
    #  Enter a value: Ubuntu Server
    ```

    Describe the operating system you wish to use for the virtual machine in at least two words separated  by spaces. Code fetches the latest image owned by Amazon and matching your description. The matching is case-insensitive.

    ```
    # Changes to Outputs:
    #  + ami_link           = "https://eu-north-1.console.aws.amazon.com/ec2/home?region=eu-north-1#ImageDetails:imageId=ami-068011ee7bf544493"
    #  + image_ami_id       = "ami-068011ee7bf544493"
    #  + image_name         = "ubuntu/images-testing/hvm-ssd-gp3/ubuntu-questing-daily-amd64-server-20250601"
    #  + instance_public_ip = (known after apply)
    ```

    Check the AMI image ID in the Amazon AMI database to make sure you are satisfied with the image. There should be a direct link to the image in Amazon console for your region in the output of the "terraform plan" command.

    `terraform apply`

   # If you are done using the EC2

    `terraform destroy`
