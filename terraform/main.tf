resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name: "my-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my-vpc.vpc_id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name: "my-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.vpc_id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-rtb" {
  vpc_id = aws_vpc.my-vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name: "my-rtb"
  }
}

resource "aws_route_table_association" "my-rtb-association" {
  subnet_id = aws_subnet.my_subnet.subnet_id
  route_table_id = aws_route_table.my-rtb.id
}