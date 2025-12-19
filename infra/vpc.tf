resource "aws_vpc" "capstone_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "capstone-vpc"
  }
}


#==========INTERNET GATEWAY===================
resource "aws_internet_gateway" "capstone_igw" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name = "capstone-igw"
  }
}



#==========PUBLIC SUBNETS=====================
resource "aws_subnet" "capstone_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "capstone-public-subnet-${count.index + 1}"
  }
}



#============PRIVATE SUBNETS====================
resource "aws_subnet" "capstone_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)

  tags = {
    Name = "capstone-private-subnet-${count.index + 1}"
  }
}



#==============NAT GATEWAY=====================
resource "aws_eip" "capstone_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "capstone-nat-eip"
  }
}

resource "aws_nat_gateway" "capstone_nat" {
  allocation_id = aws_eip.capstone_nat_eip.id
  subnet_id     = aws_subnet.capstone_public_subnet[0].id

  tags = {
    Name = "capstone-nat-gateway"
  }
}



#===============ROUTE TABLES====================
resource "aws_route_table" "capstone_public_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone_igw.id
  }

  tags = {
    Name = "capstone-public-rt"
  }
}


resource "aws_route_table" "capstone_private_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.capstone_nat.id
  }

  tags = {
    Name = "capstone-private-rt"
  }
}



#=================ROUTE TABLE ASSOCIATIONS==============
resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.capstone_public_subnet[count.index].id
  route_table_id = aws_route_table.capstone_public_rt.id
}


resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.capstone_private_subnet[count.index].id
  route_table_id = aws_route_table.capstone_private_rt.id
}

