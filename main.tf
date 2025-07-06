# specify provider version constraints

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0-beta1"
    }

  }
}

# define aws provider

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# read admin rsa pubkey from module directory

data "local_file" "rsa_pubkey" {
  filename = "${path.root}/admin_key.pub"
}

# deploy admin ssh keypair

resource "aws_key_pair" "terraform_rsa_pubkey" {
  key_name   = "terraform_admin_ssh_key"
  public_key = data.local_file.rsa_pubkey.content
}

# query the ami using provided ami id to check if it is windows-based (to determine if password data should be retrieved)

data "aws_ami" "ami_query" {
  filter {
    name   = "image-id"
    values = ["${var.aws_ami}"]
  }
}

# query the available instance types for the ami architecture provided for the validation rule for instance_type variable

data "aws_ec2_instance_types" "instance_types_query" {
  filter {
    name   = "processor-info.supported-architecture"
    values = ["${local.ami_arch}"]
  }
}

data "aws_ec2_instance_type" "instance_type_info" {
  instance_type = var.aws_instance_type
}

locals {
  ami_arch                = data.aws_ami.ami_query.architecture
  ami_platform            = data.aws_ami.ami_query.platform
  ami_instance_types      = data.aws_ec2_instance_types.instance_types_query.instance_types
  instance_type_vcpus     = data.aws_ec2_instance_type.instance_type_info.default_vcpus != null ? data.aws_ec2_instance_type.instance_type_info.default_vcpus : "Not specified"
  instance_type_memory    = data.aws_ec2_instance_type.instance_type_info.memory_size != null ? data.aws_ec2_instance_type.instance_type_info.memory_size : "Not specified"
  instance_type_storage   = data.aws_ec2_instance_type.instance_type_info.total_instance_storage != null ? data.aws_ec2_instance_type.instance_type_info.total_instance_storage : "Not specified"
  instance_type_free_tier = data.aws_ec2_instance_type.instance_type_info.free_tier_eligible != null ? data.aws_ec2_instance_type.instance_type_info.free_tier_eligible : "Not specified"
  instance_type_net_perf  = data.aws_ec2_instance_type.instance_type_info.network_performance != null ? data.aws_ec2_instance_type.instance_type_info.network_performance : "Not specified"
}

# deploy a new ec2 vm resource

resource "aws_instance" "terraform_quick_ec2" {
  provider                    = aws
  ami                         = var.aws_ami
  instance_type               = var.aws_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ingress_remote_management.id]
  subnet_id                   = aws_subnet.dev_subnet.id
  key_name                    = aws_key_pair.terraform_rsa_pubkey.id
  get_password_data           = local.ami_platform == "windows" ? true : false
  tags = {
    Name              = "terraform_quick_ec2"
    public_access     = true
    terraform_managed = true
  }
}
