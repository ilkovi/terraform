terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.0.0"
}

# set region
provider "aws" {
  region  = "${var.aws_region}"
}



# Provides a Resource Group
resource "aws_resourcegroups_group" "resource_group" {
  name = "rg_demo"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "resource_group",
      "Values": ["demo_rg_vpc"]
    }
  ]
}
JSON
  }
}



# crate VPC
resource "aws_vpc" "vpc_demo" {
  cidr_block = "${var.vpc_prefix}"

  tags = {
    resource_group 	= "rg_demo"
    Name 		= "VPC Demo"
  }
}



# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            	= aws_vpc.vpc_demo.id
  cidr_block        	= "${var.public_subnet_prefix}"
#  availability_zone 	= "us-east-1b"

  tags = {
    resource_group      = "rg_demo"
    Name 		= "PUBLIC net"
  }
}



# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            	= aws_vpc.vpc_demo.id
  cidr_block        	= "${var.private_subnet_prefix}"
  availability_zone 	= "us-east-1a"

  tags = {
    resource_group      = "rg_demo"
    Name 		= "PRIVATE net"
  }
}



# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_demo.id}"


  tags = {
    resource_group      = "rg_demo"
    Name 		= "IG Demo"
  }
}




# Create NAT Gateway and relate to Private subnet
resource "aws_nat_gateway" "nat_gw" {
  connectivity_type 	= "private"
  subnet_id     	= aws_subnet.private_subnet.id

  tags = {
    resource_group      = "rg_demo"
    Name 		= "NAT gw demo"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on 		= [aws_internet_gateway.gw]
}




# Create Private Route Table with NAT GW
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags = {
    resource_group      = "rg_demo"
    Name 		= "Private RT"
  }
}



# Create Public Route Table with Route to IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    resource_group      = "rg_demo"
    Name 		= "Public RT"
  }
}


# Assign the Public route table to the public Subnet
resource "aws_route_table_association" "pub-pub-ass" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}



# Assign the Private route table to the Private Subnet
resource "aws_route_table_association" "pri-pri-ass" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}


# Assign Key Pair to instance
resource "aws_key_pair" "default" {
  key_name   = "aws_key_pair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}




# Create Security Group
resource "aws_security_group" "demo_sec_group" {
  vpc_id      = "${aws_vpc.vpc_demo.id}"
  description = "terraform"

  # Allow ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    resource_group      = "rg_demo"
    Name                = "SG Demo"
  }

}

