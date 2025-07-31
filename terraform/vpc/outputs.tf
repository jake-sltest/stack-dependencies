output "subnetId" {
  description = "ID of the Subnet"
  value       = aws_subnet.sd_subnet.id
}

output "vpcId" {
  description = "ID of the Subnet"
  value       = aws_vpc.sd_vpc.id
}
