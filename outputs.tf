output "instance_public_ip" {
  description = "Deployed EC2 instance public IP (available to connect to via SSH/RDP with the pubkey provided to Terraform)"
  value       = aws_instance.terraform_quick_ec2.public_ip
}

output "image_name" {
  description = "Name of the AMI system image that was used for the EC2 Instance"
  value       = data.aws_ami.ami_query.name
}

output "image_ami_id" {
  description = "AMI value of the image to check for validity and cost"
  value       = var.aws_ami
}

output "ami_link" {
  description = "Link to the AMI image in AWS console"
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#ImageDetails:imageId=${var.aws_ami}"
}

# display administrator password conditionally if the ec2 is on windows image capable of RDP connections
# and administrator password is generated and exported for the instance

output "windows_administrator_password" {
  description = "Administrator password for the Windows machine (for example, for RDP connection purposes)"
  value       = aws_instance.terraform_quick_ec2.password_data != "" ? rsadecrypt(aws_instance.terraform_quick_ec2.password_data, file("${path.root}/admin_key")) : null
}
