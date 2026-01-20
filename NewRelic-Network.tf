provider "aws" {
  region = var.aws_region
}

#####################
# Subnets
#####################

resource "aws_subnet" "public_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_public_1_cidr
  availability_zone       = var.az1_name
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.stack_name}-Public1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_public_2_cidr
  availability_zone       = var.az2_name
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.stack_name}-Public2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_private_web_1_cidr
  availability_zone = var.az1_name

  tags = {
    Name = "${var.stack_name}-PrivateWeb1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_private_web_2_cidr
  availability_zone = var.az2_name

  tags = {
    Name = "${var.stack_name}-PrivateWeb2"
  }
}

#####################
# Route Tables
#####################

resource "aws_route_table" "public_rt_az1" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.stack_name}-Public1"
  }
}

resource "aws_route_table" "public_rt_az2" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.stack_name}-Public2"
  }
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.stack_name}-Private1"
  }
}

resource "aws_route_table" "private_rt_az2" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.stack_name}-Private2"
  }
}

#####################
# Route Associations
#####################

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt_az1.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt_az2.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_az2.id
}

#####################
# Internet Gateway
#####################

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.stack_name}-IGW"
  }
}

#####################
# NAT Gateways + EIPs
#####################

resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"
  tags = {
    Name = "${var.stack_name}-EIP1"
  }
}

resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_1.id
  tags = {
    Name = "${var.stack_name}-NAT1"
  }
}

resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"
  tags = {
    Name = "${var.stack_name}-EIP2"
  }
}

resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_2.id
  tags = {
    Name = "${var.stack_name}-NAT2"
  }
}

#####################
# Routes
#####################

# Public → IGW
resource "aws_route" "public_az1_igw" {
  route_table_id         = aws_route_table.public_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_az2_igw" {
  route_table_id         = aws_route_table.public_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Private → NAT
resource "aws_route" "nat_az1" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az1.id
}

resource "aws_route" "nat_az2" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az2.id
}

# Private → MGMT ENI
resource "aws_route" "az1_mgmt_10" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id   = var.mgmt_eni_az1
}

resource "aws_route" "az1_mgmt_192" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "192.168.0.0/16"
  network_interface_id   = var.mgmt_eni_az1
}

resource "aws_route" "az1_mgmt_172" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "172.16.0.0/12"
  network_interface_id   = var.mgmt_eni_az1
}

resource "aws_route" "az2_mgmt_10" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id   = var.mgmt_eni_az2
}

resource "aws_route" "az2_mgmt_192" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "192.168.0.0/16"
  network_interface_id   = var.mgmt_eni_az2
}

resource "aws_route" "az2_mgmt_172" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "172.16.0.0/12"
  network_interface_id   = var.mgmt_eni_az2
}
