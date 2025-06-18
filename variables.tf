# declare user information needed for terraform to deployed

variable "aws_access_key" {
  type        = string
  description = "AWS API admin access key"
  sensitive   = true
}
variable "aws_secret_key" {
  type        = string
  description = "AWS API admin secret key"
  sensitive   = true
}
variable "aws_instance_type" {
  type        = string
  description = "Type of EC2 Instance"
}
variable "aws_region" {
  type        = string
  description = "Region the EC2 Instance will be deployed to"
}
variable "aws_ami" {
  type = string
  description = "AMI image ID to be used by EC2"
  validation  {
    condition = length(var.aws_ami) > 4 && substr(var.aws_ami, 0, 4) == "ami-"
  error_message = "Enter valid AMI name starting with \"ami-\""    
  }
}
variable "ingress_ports" {
  type        = map(string)
  description = "Ingress ports for the Security Group"
  default = {
    "SSH" = "22"
    "RDP" = "3389"
  }
}
