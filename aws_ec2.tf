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
    name = "processor-info.supported-architecture"
    values = ["${local.ami_arch}"]
  }
}

locals {
  ami_arch = data.aws_ami.ami_query.architecture
  ami_platform = data.aws_ami.ami_query.platform
  ami_instance_types = data.aws_ec2_instance_types.instance_types_query.instance_types
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
