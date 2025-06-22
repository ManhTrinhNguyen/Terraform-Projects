# VPC Id
output "vpc-id" {
  value = aws_vpc.my-vpc.id
}


output "rtb-id" {
  value = aws_route_table.my-rtb.id
}

output "ami-id" {
  value = data.aws_ami.my-ami.id
}

output "ec2-public_ip" {
  value = aws_instance.my-ec2.public_ip
}