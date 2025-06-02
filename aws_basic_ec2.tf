# fetch latest ami for the os provided

data "aws_ami" "region_ami" {
  owners = [ "amazon" ]
  most_recent = true
  name_regex = local.ami_name_regex_string
  region = var.aws_region
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
  filter {
    name = "owner-alias"
    values = [ "amazon" ]
  }
  filter {
    name = "state"
    values = [ "available" ]
  }
}

# deploy a new t3_micro ec2 vm resource

resource "aws_instance" "terraform_managed_ec2" {
  provider = aws
  ami           = data.aws_ami.region_ami.image_id
  instance_type = var.aws_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.ingress_ssh_egress_any.id ]
  subnet_id = aws_subnet.dev_subnet.id
  key_name = aws_key_pair.terraform_admin_ssh_key.id
    tags = {
        name = "terraform_managed_ec2"
        date_created = timestamp()
        public_access = true
    }
}
