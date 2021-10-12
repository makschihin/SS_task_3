####
#VPC
####
resource "aws_vpc" "new_vpc" {
    cidr_block = var.def_vpc
}

# Internet Gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.new_vpc.id
}
/*
# Public subnets
resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.new_vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.new_vpc.id
  map_public_ip_on_launch = true
}
*/

#Public subnets
resource "aws_subnet" "public_sub_1" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = var.public_sub_1
  availability_zone = var.private1_az
  map_public_ip_on_launch = true #for test
}

resource "aws_subnet" "public_sub_2" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = var.public_sub_2
  availability_zone = var.private2_az
  map_public_ip_on_launch = true #for test
}
# Privat subnets
resource "aws_subnet" "private_sub_1" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = var.private_subnet_1
  availability_zone = var.private1_az
}

resource "aws_subnet" "private_sub_2" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = var.private_subnet_2
  availability_zone = var.private2_az
}


# Route table for Public Subnets
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  } 
}

# Route table association with Public Subnets
resource "aws_route_table_association" "PublicRTassociation_1" {
  subnet_id      = aws_subnet.public_sub_1.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table_association" "PublicRTassociation_2" {
  subnet_id      = aws_subnet.public_sub_2.id
  route_table_id = aws_route_table.publicRT.id
}

# Route table for Private Subnets
/*resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}

# Route table association with Private Subnets
resource "aws_route_table_association" "PrivateRTassociation_1" {
  subnet_id      = aws_subnet.private_sub_1.id
  route_table_id = aws_route_table.privateRT.id
}

resource "aws_route_table_association" "PrivateRTassociation_2" {
  subnet_id      = aws_subnet.private_sub_2.id
  route_table_id = aws_route_table.privateRT.id
}

#############################################################################
# NAT
#############################################################################
resource "aws_eip" "nateIP" {
  vpc   = true
 }
# Creating the NAT Gateway using subnet_id
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.public_sub_1.id
}
*/
/*resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.test_igw]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}
*/
#################################################################################################
/*
####
#Subnets
####
resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.new_vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.new_vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.new_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.new_vpc.id
}

####
#IGW
####
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.new_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.new_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

####
#NAT
####
resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

####
#Route tables
####
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
#################################################################################################
*/

