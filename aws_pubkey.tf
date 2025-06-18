# read admin rsa pubkey from module directory

data "local_file" "rsa_pubkey" {
  filename = "${path.root}/admin_key.pub"
}

# deploy admin ssh keypair

resource "aws_key_pair" "terraform_rsa_pubkey" {
  key_name   = "terraform_admin_ssh_key"
  public_key = data.local_file.rsa_pubkey.content
}
