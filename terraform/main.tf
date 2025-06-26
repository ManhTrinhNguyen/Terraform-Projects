resource "aws_vpc" "my-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.env_prefix}-my-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.env_prefix}-my-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.env_prefix}-my-igw"
  }
}

resource "aws_route_table" "my-rtb" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-my-rtb"
  }
}

resource "aws_route_table_association" "my-rtb-association" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my-rtb.id
}

resource "aws_security_group" "my-sg" {
  name = "My SG"
  description = "Allow SSH for only my Address and Open port 8080 for my Application"
  vpc_id = aws_vpc.my-vpc.id 

  tags = {
    Name = "${var.env_prefix}-my-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = var.my_ip_address
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22 
}

resource "aws_vpc_security_group_ingress_rule" "allow-SSH-jenkins" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = var.jenkins_ip_address
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22 
}

resource "aws_vpc_security_group_ingress_rule" "application-port-8080" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8080
  ip_protocol = "tcp"
  to_port = 8080 
}

resource "aws_vpc_security_group_egress_rule" "allow-to-egress-to-internet" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

data "aws_ami" "my-ami" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "my-ec2" {
  ami = data.aws_ami.my-ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet.id
  availability_zone = var.availability_zone
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]

  associate_public_ip_address = true
  
  key_name = var.my_key_name

  user_data = "./entry-script.sh"

  user_data_replace_on_change = true
  tags = {
    Name = "${var.env_prefix}-dev-ec2"
  }
}