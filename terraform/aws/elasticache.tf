# resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
#   name       = "elasticache-subnet-group"
#   subnet_ids = [aws_subnet.private-subnet-c.id]
# }


# resource "aws_elasticache_replication_group" "elasticache-replication-group-dev" {
#   replication_group_id          = "${var.system}-dev-elascache-rep-group"
#   replication_group_description = "Redis cluster for DEV environment"

#   node_type            = "cache.t4g.micro"
#   port                 = 6379
#   parameter_group_name = "default.redis7"
#   engine_version       = "7.0"

#   snapshot_retention_limit = 5
#   snapshot_window          = "00:00-05:00"

#   subnet_group_name          = aws_elasticache_subnet_group.elasticache-subnet-group.name
#   automatic_failover_enabled = false # Disable cluster mode

#   security_group_ids = [aws_security_group.databases.id]

#   transit_encryption_enabled = true
#   auth_token =  "automate-all-the-things-dev"

#   cluster_mode {
#     replicas_per_node_group = 1
#   }
# }

# resource "aws_elasticache_replication_group" "elasticache-replication-group-stage" {
#   replication_group_id          = "${var.system}-stage-elascache-rep-group"
#   replication_group_description = "Redis cluster for STAGE environment"

#   node_type            = "cache.t4g.micro"
#   port                 = 6379
#   parameter_group_name = "default.redis7"
#   engine_version       = "7.0"

#   snapshot_retention_limit = 5
#   snapshot_window          = "00:00-05:00"

#   subnet_group_name          = aws_elasticache_subnet_group.elasticache-subnet-group.name
#   automatic_failover_enabled = false # Disable cluster mode

#   security_group_ids = [aws_security_group.databases.id]

#   transit_encryption_enabled = true
#   auth_token =  "automate-all-the-things-stage"

#   cluster_mode {
#     replicas_per_node_group = 1
#   }
# }

# resource "aws_elasticache_replication_group" "elasticache-replication-group-prod" {
#   replication_group_id          = "${var.system}-prod-elascache-rep-group"
#   replication_group_description = "Redis cluster for PROD environment"

#   node_type            = "cache.t4g.micro"
#   port                 = 6379
#   parameter_group_name = "default.redis7"
#   engine_version       = "7.0"

#   snapshot_retention_limit = 5
#   snapshot_window          = "00:00-05:00"

#   subnet_group_name          = aws_elasticache_subnet_group.elasticache-subnet-group.name
#   automatic_failover_enabled = false # Disable cluster mode

#   security_group_ids = [aws_security_group.databases.id]

#   transit_encryption_enabled = true
#   auth_token =  "automate-all-the-things-prod"

#   cluster_mode {
#     replicas_per_node_group = 1
#   }
# }

