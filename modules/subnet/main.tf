resource "aws_subnet" "my-subnet-public-1" {

  cidr_block              = var.subnet_cidr_blocks[0]
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.environment}-my-puclic-subnet-1"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = var.vpc_id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    "Name" = "${var.environment}-public-rt"
  }


}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = var.vpc_id

  tags = {
    "Name" = "my-igw"
  }
}

resource "aws_route_table_association" "my-subnet-assoc" {
  subnet_id      = aws_subnet.my-subnet-public-1.id
  route_table_id = aws_route_table.public-rt.id
}