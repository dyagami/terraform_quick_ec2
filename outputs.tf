output "instance_public_ip" {
    description = "Deployed EC2 instance public IP (available to connect to via SSH/RDP with the pubkey provided to Terraform)"
    value = aws_instance.terraform_managed_ec2.public_ip
}

output "image_name" {
  description = "Name of the AMI system image that was used for the EC2 Instance"
  value = data.aws_ami.region_ami.name
}

output "image_ami_id" {
  description = "AMI value of the image to check for validity and cost"
  value = data.aws_ami.region_ami.image_id
}

output "ami_link" {
  description = "Link to the AMI image in AWS console"
  value = "https://${var.aws_region}.console.aws.amazon.com/ec2/home?region=${var.aws_region}#ImageDetails:imageId=${data.aws_ami.region_ami.image_id}"
}
