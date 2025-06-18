data "aws_ami" "query_ami" {
  filter {
    name   = "image-id"
    values = ["${var.aws_ami}"]
  }
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
  get_password_data           = data.aws_ami.query_ami.platform == "windows" ? true : false
  tags = {
    Name              = "terraform_quick_ec2"
    public_access     = true
    terraform_managed = true
  }
}
