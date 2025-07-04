# AWS quick remote access EC2 instance setup with Terraform

A Terraform configuration to quickly spin up an AWS EC2 VM with SSH/RDP over-the-internet access. Ideal for temporary use cases like development or testing. Highly discouraged in production environments due to remote access ports being exposed by firewall directly to the internet.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed
- AWS account with [IAM credentials](https://www.youtube.com/watch?v=OZsmKaIz_M0)
- OpenSSH client installed
- (Optionally - if you want to deploy a Windows VM) RDP client

***

## Setup Instructions

1. **Prepare Your Environment**

2. **Clone this repository** ```git clone https://github.com/dyagami/terraform_quick_ec2.git```

3. **Create an IAM user and generate an Access Key with the following permissions:**
    - `AmazonEC2FullAccess`
    - `IAMReadOnlyAccess` (for Terraform to read IAM resources)

4. **Configure Variables**

   - **Preferrable way**

        Set up the following environment variables prior to launching the code:

        ```
        TF_VAR_aws_access_key    = "YOUR_ACCESS_KEY"
        TF_VAR_aws_secret_key    = "YOUR_SECRET_KEY"
        TF_VAR_aws_region        = "YOUR_REGION"        
        TF_VAR_aws_ami           = "AMI_IMAGE_ID"
        TF_VAR_aws_instance_type = "INSTANCE_TYPE"
        ```

        Example:

        ```
        TF_VAR_aws_access_key    = "XYZ"
        TF_VAR_aws_secret_key    = "XYZ"
        TF_VAR_aws_region        = "eu-north-1"        
        TF_VAR_aws_ami           = "ami-0f62af003039dfaa6"
        TF_VAR_aws_instance_type = "t3.micro"
        ```

   - **Unsecure way (storing secrets in plaintext - only do it if you know the repercussions)**

        Edit `terraform.tfvars` file in your working directory with:

        ```
        aws_access_key    = "YOUR_ACCESS_KEY" 
        aws_secret_key    = "YOUR_SECRET_KEY"
        aws_region        = "YOUR_REGION"        
        aws_ami           = "AMI_IMAGE_ID"
        aws_instance_type = "INSTANCE_TYPE"
        ```

        Example:

        ```
        aws_access_key    = "XYZ" 
        aws_secret_key    = "XYZ"
        aws_region        = "eu-north-1"        
        aws_ami           = "ami-068011ee7bf544493"
        aws_instance_type = "t3.micro"
        ```

5. **Generate RSA key pair**

    `ssh-keygen -t rsa -b 4096 -m PEM -N "" -f ./admin_key`

    This command will generate an *SSH RSA 4096 bit key pair in PEM format* in the project's directory using filename "admin_key" with no password on the private key..

    - When you deploy the infrastructure

        - Terraform will create an AWS keypair resource using the public key
        - For a Linux VM
            - Terraform will add the public key to the instance SSH server's authorized_keys, so that you're able to connect to the instance via SSH using the private key `ssh -i ./admin_key USER@IP`.
            - Terraform will only display the public IP for SSH access. The default SSH usernames in AWS are different for different Linux distribution images. Full reference list can be found [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html#ami-default-user-names).

        - For a Windows VM
            - AWS will generate an Administrator user password for the instance and will encrypt it using the public key.
            - Terraform will retrieve the encrypted password and will decrypt it using the private key.
            - Terraform will will display the decrypted password along with the public IP of the instance that you can paste into your RDP client.

6. **Run Terraform Commands**

    ```
    terraform init
    terraform plan

    (...)

    + ami_link                       = "https://eu-north-1.console.aws.amazon.com/ec2/home?region=eu-north-1#ImageDetails:imageId=ami-068011ee7bf544493"
    + image_ami_id                   = "ami-068011ee7bf544493"
    + image_name                     = "ubuntu/images-testing/hvm-ssd-gp3/ubuntu-questing-daily-amd64-server-20250601"
    + instance_public_ip             = (known after apply)
    + instance_type_details          = {
        + "Free Tier Eligible"       = "true"
        + "Network Card Performance" = "Up to 5 Gigabit"
        + "Selected Instance Type"   = "t3.micro"
        + "Total RAM (MiB)"          = "1024"
        + "Total Storage (GB)"       = "Not specified"
        + "vCPU Cores"               = "2"
        }
    + windows_administrator_password = (known after apply)    
    ```

    Terraform will output the ami image ID and name along with a direct link to the AMI image in AWS catalog aligned to your specified region for a quick double-check of the image before applying the infrastructure. The details of the instance type including vCPUs, RAM, storage, network card interface speed and instance eligibility for the free plan will also be displayed, if they are embedded in the instance type metadata.

    If you specify a wrong instance type for the provided AMI image architecture, the code will generate an error and provide you with available instance types for this AMI. AWS has different instance type naming conventions for certain architectures like arm64.

    ```
    ╷
    │ Error: Invalid value for variable
    │ 
    │   on terraform.tfvars line 3:
    │    3: aws_instance_type = "t3.micro"
    │     ├────────────────
    │     │ local.ami_instance_types is list of string with 159 elements
    │     │ var.aws_instance_type is "t3.micro"
    │ 
    │ Wrong instance type for the arm64 architecture that the AMI image is based on. Please select one of the following instance types that are available for the arm64 architecture: 
    │ 
    │ m8g.8xlarge, c7g.16xlarge, r6gd.2xlarge, r8g.4xlarge, c6gd.metal, r6g.medium, r6g.8xlarge, m6gd.xlarge, m8g.24xlarge, c8g.8xlarge, r6gd.xlarge, m7gd.16xlarge, r8g.12xlarge, r8g.16xlarge, m7g.4xlarge, m6gd.4xlarge, r6g.large, t4g.nano, m7gd.large, m6gd.medium, m7g.large,
    │ r6gd.medium, m7gd.xlarge, c8g.24xlarge, c6gn.16xlarge, c6g.16xlarge, c7g.8xlarge, r6g.16xlarge, m6gd.12xlarge, r7gd.8xlarge, c7gd.medium, r8g.metal-24xl, m8g.large, c8g.2xlarge, m8g.metal-48xl, c8g.48xlarge, m6g.metal, r7gd.16xlarge, r8g.large, t4g.2xlarge, c7g.xlarge, r8g.medium,
    │ m6g.xlarge, m8g.16xlarge, c6gn.xlarge, r7gd.xlarge, c6gn.4xlarge, m6gd.16xlarge, c8g.large, m7g.16xlarge, r7g.medium, c7g.4xlarge, r6gd.metal, r7g.2xlarge, c6g.xlarge, t4g.medium, c6g.12xlarge, m6gd.metal, c7gd.16xlarge, m7g.12xlarge, r7g.xlarge, r6gd.large, m7gd.12xlarge,
    │ r6g.4xlarge, r7g.metal, m7gd.8xlarge, c6gn.12xlarge, c8g.metal-48xl, r7g.8xlarge, r6g.12xlarge, m7g.xlarge, r7gd.2xlarge, m7gd.medium, m7g.8xlarge, t4g.small, c8g.12xlarge, r7gd.medium, r8g.48xlarge, m6g.4xlarge, c6gn.medium, m8g.12xlarge, c6gd.xlarge, m8g.4xlarge, m8g.xlarge,
    │ m7gd.4xlarge, m6g.8xlarge, r8g.24xlarge, c6gd.16xlarge, c7gd.large, c7gd.xlarge, r7gd.4xlarge, t4g.large, m6g.large, c6g.large, r6gd.4xlarge, m7gd.metal, c6gn.large, c8g.medium, m6g.16xlarge, m8g.48xlarge, r7gd.metal, t4g.micro, m8g.2xlarge, r7gd.large, c7gd.metal, r8g.metal-48xl,
    │ r7g.4xlarge, c7gd.8xlarge, c7g.large, c6gn.8xlarge, c7g.metal, c7g.medium, m7g.metal, r6gd.8xlarge, c6gn.2xlarge, m7g.2xlarge, m7g.medium, c7g.2xlarge, r8g.xlarge, c8g.metal-24xl, m6gd.8xlarge, m6g.12xlarge, c7gd.2xlarge, c7gd.12xlarge, r6gd.16xlarge, t4g.xlarge, c8g.4xlarge,
    │ c6gd.2xlarge, r6g.metal, r7g.12xlarge, c8g.16xlarge, r7g.large, m6gd.2xlarge, r6g.xlarge, r6g.2xlarge, r7gd.12xlarge, c6gd.4xlarge, c6g.2xlarge, c6g.4xlarge, c6g.medium, c8g.xlarge, r7g.16xlarge, c6g.8xlarge, m6g.medium, m6gd.large, c7gd.4xlarge, c6gd.medium, m8g.metal-24xl,
    │ c7g.12xlarge, r8g.2xlarge, m8g.medium, r6gd.12xlarge, c6gd.large, m6g.2xlarge, m7gd.2xlarge, c6gd.8xlarge, r8g.8xlarge, c6g.metal, c6gd.12xlarge
    │ 
    │ This was checked by the validation rule at variables.tf:18,3-13.    
    ```

    If you are satisfied with the plan, run `terraform apply` to deploy the infrastructure.

7. **Connect to the newly created VM instance**

    - If you deployed a Linux machine

        After obtaining the public IP you can connect to the instance by using `ssh -i ./admin_key USER@INSTANCE_IP`. The default SSH usernames for different Linux distributions deployed in AWS can be found [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html#ami-default-user-names).

    - If you deployed a Windows machine

        After obtaining the public IP and the Administrator password, you can enter them in your RDP client of choice, logging in as "Administrator" to a default domain "WORKGROUP".

        Example using Linux and xfreerdp3:
        `xfreerdp3 /u:Administrator /d:"WORKGROUP" /v:"IP_ADDRESS" /p:"PASSWORD"`

### If you are done using the EC2

    `terraform destroy`
