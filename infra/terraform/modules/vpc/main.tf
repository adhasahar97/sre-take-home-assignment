resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

# Enable auto-assign public IPs for the VPC: https://github.com/hashicorp/terraform/issues/263
resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone = "ap-southeast-5a"

  tags = {
    Name = "subnet_a"
    "kubernetes.io/role/elb" = "1"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 2)
  availability_zone = "ap-southeast-5b"

  tags = {
    Name = "subnet_b"
    "kubernetes.io/role/elb" = "1"
  }
  map_public_ip_on_launch = true
}

# resource "aws_subnet" "subnet_c" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 3)
#   availability_zone = "ap-southeast-1c"

#   tags = {
#     Name = "subnet_c"
#   }
# }

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

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.feedme-sre-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.feedme-sre-rt.id
}

# resource "aws_route_table_association" "c" {
#   subnet_id      = aws_subnet.subnet_c.id
#   route_table_id = aws_route_table.feedme-sre-rt.id
# }