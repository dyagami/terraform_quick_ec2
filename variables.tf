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
  validation {
    condition = contains(local.ami_instance_types[*], var.aws_instance_type)
    error_message = "Wrong instance type for the ${local.ami_arch} architecture that the AMI image is based on. Please select one of the following instance types that are available for the ${local.ami_arch} architecture: \n\n${join(", ", local.ami_instance_types[*])}"
  }
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
