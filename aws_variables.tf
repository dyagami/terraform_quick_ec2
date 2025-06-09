# declare user information needed for terraform to deployed

variable "admin_pubkey" {
  type        = string
  description = "Full SSH public key line to use for SSH admin authentication (or RDP admin password decryption)"
  sensitive   = true
}
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
variable "ingress_ports" {
  type = list(number)
  description = "Ingress ports for the Security Group"
  default = [ 22, 3389 ]
}
# declare OS name with at least 2 words

variable "os" {
  type        = string
  description = "Enter OS name - use at least 2 words separated by spaces to avoid mismatch"
  validation {
    condition     = length(regexall("\\w\\s.*\\w.*", var.os)) > 0
    error_message = "Enter valid OS name - use at least 2 words separated by spaces to avoid mismatch"
  }
}

# parse OS name to a list and join elements to variable containing case-insensitive regex string

locals {
  os_split              = split(" ", var.os)
  ami_name_regex_string = format(".*(?i)%s.*", join(".*", local.os_split))
}
