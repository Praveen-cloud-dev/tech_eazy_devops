
# Availability Zones Data Source
############################################
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
############################################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "dev-vpc" }
}

############################################
# INTERNET GATEWAY
############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "dev-igw" }
}

############################################
# PUBLIC SUBNETS
############################################
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet("10.0.0.0/16", 4, count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "public-subnet-${count.index}" }
}

############################################
# PRIVATE SUBNETS
############################################
resource "aws_subnet" "private" {
  count = 3
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet("10.0.0.0/16", 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "private-subnet-${count.index}" }
}

############################################
# PUBLIC ROUTE TABLE
############################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

############################################
# NAT GATEWAY (for private EC2 internet)
############################################
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat_eip.id
  tags = { Name = "dev-nat" }
}

############################################
# PRIVATE ROUTE TABLE
############################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
