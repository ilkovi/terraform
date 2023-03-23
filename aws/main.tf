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
  region  = "us-east-1"
}


# crate VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}


# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-example"
  }
}

# Create Network Interface
resource "aws_network_interface" "ni1-app_server" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

# Create Instance
resource "aws_instance" "app_server" {
  ami           = "ami-02f3f602d23f1659d" 	# us-east-1
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.ni1-app_server.id
    device_index         = 0
  }

  tags = {
    Name = "Demo System"
  }
}

