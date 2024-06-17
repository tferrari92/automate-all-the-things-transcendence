output "vps_id" {
  value = aws_vpc.main.id
}

output "database_subnet_id" {
  value = aws_subnet.private-subnet-c.id
}

# output "database_security_group_id" {
#   value = aws_security_group.databases.id
# }

# output "elasticache_dev_primary_endpoint_address" {
#   value = aws_elasticache_replication_group.elasticache-replication-group-dev.primary_endpoint_address
# }

# output "elasticache_stage_primary_endpoint_address" {
#   value = aws_elasticache_replication_group.elasticache-replication-group-stage.primary_endpoint_address
# }

# output "elasticache_prod_primary_endpoint_address" {
#   value = aws_elasticache_replication_group.elasticache-replication-group-prod.primary_endpoint_address
# }
