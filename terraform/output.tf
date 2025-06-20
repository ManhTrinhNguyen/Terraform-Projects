# VPC Id
output "vpc-id" {
  value = aws_vpc.my-vpc.id
}


output "rtb-id" {
  value = aws_route_table.my-rtb.id
}
