#-------------------------------------------------------
# VPC
#-------------------------------------------------------
resource "aws_vpc" "TeradaVPC" {
  cidr_block           = var.cidr_block_VPC
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name        = "vpc-${var.NameBase}"
    Environment = var.env
  }
}
#-------------------------------------------------------
# PubricSubnet
#-------------------------------------------------------
locals {
  public_subnets = {
    "1a" = {
      cidr_block = var.cidr_block_PublicSubnet1a
      availability_zone = var.AZ_1a
    },
    "1b" = {
      cidr_block = var.cidr_block_PublicSubnet1b
      availability_zone = var.AZ_1b
    }
  }
}

resource "aws_subnet" "TeradaPublicSubnet" {
  for_each = local.public_subnets

  cidr_block = each.value.cidr_block

  vpc_id                  = aws_vpc.TeradaVPC.id
  map_public_ip_on_launch = true

  availability_zone = each.value.availability_zone

  tags = {
    Name        = "publicsubnet${each.key}-${var.NameBase}"
    Environment = var.env
  }
}
#-------------------------------------------------------
# PrivateSubnet
#-------------------------------------------------------
locals {
  private_subnets = {
    "1a" = {
      cidr_block = var.cidr_block_PrivateSubnet1a
      availability_zone = var.AZ_1a
    },
    "1b" = {
      cidr_block = var.cidr_block_PrivateSubnet1b
      availability_zone = var.AZ_1b
    }
  }
}

resource "aws_subnet" "TeradaPrivateSubnet" {
  for_each = local.private_subnets

  cidr_block = each.value.cidr_block

  vpc_id                  = aws_vpc.TeradaVPC.id
  map_public_ip_on_launch = false

  availability_zone = each.value.availability_zone

  tags = {
    Name        = "PrivateSubnet${each.key}-${var.NameBase}"
    Environment = var.env
  }
}
#-------------------------------------------------------
# InternetGateway
#-------------------------------------------------------
resource "aws_internet_gateway" "TeradaInternetGateway" {
  tags = {
    Name        = "iGW-${var.NameBase}"
    Environment = var.env
  }
}
resource "aws_internet_gateway_attachment" "AttachGateway" {
  internet_gateway_id = aws_internet_gateway.TeradaInternetGateway.id
  vpc_id              = aws_vpc.TeradaVPC.id
}
#-------------------------------------------------------
# PublicRouteTable
#-------------------------------------------------------
resource "aws_route_table" "PublicrouteTable" {
  vpc_id = aws_vpc.TeradaVPC.id

  tags = {
    Name        = "PublicRouteTable-${var.NameBase}"
    Environment = var.env
  }
}
resource "aws_route" "Publicroute" {
  route_table_id         = aws_route_table.PublicrouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.TeradaInternetGateway.id
}

resource "aws_route_table_association" "TeradaPublicSubnetRouteTableAssociation" {
  for_each = aws_subnet.TeradaPublicSubnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.PublicrouteTable.id
}
#-------------------------------------------------------
# PrivateRouteTable
#-------------------------------------------------------
resource "aws_route_table" "PrivaterouteTable" {
  vpc_id = aws_vpc.TeradaVPC.id

  tags = {
    Name        = "PrivateRouteTable-${var.NameBase}"
    Environment = var.env
  }
}
resource "aws_route_table_association" "TeradaPrivateSubnetRouteTableAssociation" {
  for_each = aws_subnet.TeradaPrivateSubnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.PrivaterouteTable.id
}
#-------------------------------------------------------
# OutPuts
#-------------------------------------------------------
output "VPCoutputs" {
  description = "VPC output"
  value       = aws_vpc.TeradaVPC.id
}

output "PublicSubnet1aoutputs" {
  description = "publicSubnet1a output"
  value       = aws_subnet.TeradaPublicSubnet["1a"].id
}

output "PublicSubnet1boutputs" {
  description = "publicSubnet1b output"
  value       = aws_subnet.TeradaPublicSubnet["1b"].id
}

output "PrivateSubnet1aoutputs" {
  description = "PrivateSubnet1a output"
  value       = aws_subnet.TeradaPrivateSubnet["1a"].id
}

output "PrivateSubnet1boutputs" {
  description = "PrivateSubnet1b output"
  value       = aws_subnet.TeradaPrivateSubnet["1b"].id
}
