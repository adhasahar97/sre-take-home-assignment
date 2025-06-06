resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "subnet_1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 2)
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "subnet_2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 3)
  availability_zone = "ap-southeast-1c"

  tags = {
    Name = "subnet_3"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-feedme-sre"
  }
}

resource "aws_route_table" "feedme-sre-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-feedme-sre"
  }
}