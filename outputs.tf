output "id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.main.id, null)
}

output "public_subnets" {
  description = "List of IDs of the public subnets"
  value       = try(aws_subnet.public[*].id, null)
}

output "private_subnets" {
  description = "List of IDs of the private subnets"
  value       = try(aws_subnet.private[*].id, null)
}

output "internet_gw" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.main.id, null)
}

output "nat_gws" {
  description = "List of IDs of the NAT Gateways"
  value       = try(aws_nat_gateway.main[*].id, null)
}
