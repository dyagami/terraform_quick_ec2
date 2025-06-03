# deploy a default vpc and define its cidr_block

resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
}

# deploy a /25 subnet from vpc subnet

resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.10.128/25"
}


# deploy an internet gateway to allow ingress traffic over routable networks

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
}

resource "aws_subnet" "secondary" {
  vpc_id            = aws_vpc.mainvpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, 1)
}

# deploy routes to the default route table

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.mainvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

# deploy a security group

resource "aws_security_group" "ingress_ssh_egress_any" {
  vpc_id      = aws_vpc.mainvpc.id
  name        = "ingress_ssh_any_egress_any"
  description = "ingress ssh from any, egress to any, dev only!"
  tags = {
    name = "ingress_ssh_egress_any"
  }
}

# deploy an ingress rule allowing ssh traffic from anywhere

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh" {
  security_group_id = aws_security_group.ingress_ssh_egress_any.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# deploy an ingress rule allowing rdp traffic from anywhere

resource "aws_vpc_security_group_ingress_rule" "ingress_rdp" {
  security_group_id = aws_security_group.ingress_ssh_egress_any.id
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# deploy an egress rule to any

resource "aws_vpc_security_group_egress_rule" "egress_any" {
  security_group_id = aws_security_group.ingress_ssh_egress_any.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}

