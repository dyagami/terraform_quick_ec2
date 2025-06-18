# deploy a default vpc and define its cidr block

resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name              = "terraform_main_vpc"
    terraform_managed = true
  }
}

# deploy a /25 subnet from vpc subnet

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.10.128/25"
  tags = {
    Name              = "terraform_dev_subnet"
    terraform_managed = true
  }
}


# deploy an internet gateway to allow traffic over routable networks

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.mainvpc.id
}

# fetch availability zones available for the selected region

data "aws_availability_zones" "available" {
  state = "available"
}

# deploy public subnets in two available availability zones

resource "aws_subnet" "primary" {
  vpc_id            = aws_vpc.mainvpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  tags = {
    Name              = "terraform_primary_public_subnet"
    terraform_managed = true
  }

}

resource "aws_subnet" "secondary" {
  vpc_id            = aws_vpc.mainvpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  tags = {
    Name              = "terraform_secondary_public_subnet"
    terraform_managed = true
  }

}

# deploy default route to the main route table

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.mainvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id

}

# deploy a security group

resource "aws_security_group" "ingress_remote_management" {
  vpc_id      = aws_vpc.mainvpc.id
  name        = "terraform_ingress_remote_management_sg"
  description = "ingress remote management ports over the internet and egress to any"
  tags = {
    Name              = "terraform_ingress_remote_management_sg"
    terraform_managed = true
  }
}

# deploy ingress rules for all ports specified in ingress_ports map, allowing traffic from anywhere

resource "aws_vpc_security_group_ingress_rule" "ingress_management_ports" {
  for_each          = var.ingress_ports
  security_group_id = aws_security_group.ingress_remote_management.id
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name              = "ingress_rule_${each.key}"
    terraform_managed = true
  }
}

# deploy an egress rule to any

resource "aws_vpc_security_group_egress_rule" "egress_any" {
  security_group_id = aws_security_group.ingress_remote_management.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name              = "egress_rule_any"
    terraform_managed = true
  }

}

