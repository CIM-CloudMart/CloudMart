# ==================== RDS PostgreSQL Module ====================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group-${var.environment}${var.db_subnet_group_name_suffix}"
  subnet_ids = var.private_data_subnet_ids
}

# Credentials passed directly as variables to avoid dependency race conditions during creation

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg-${var.environment}"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL"

  dynamic "ingress" {
    for_each = var.eks_cluster_sg_id != null ? [var.eks_cluster_sg_id] : []
    content {
      description     = "Allow PostgreSQL from EKS (Fargate pods or worker nodes)"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.bastion_sg_id != null ? [var.bastion_sg_id] : []
    content {
      description     = "Allow PostgreSQL from Bastion Host"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  tags = {
    Name = "${var.project}-rds-sg-${var.environment}"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.project}-postgres-pg-${var.environment}"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = {
    Name        = "${var.project}-postgres-pg-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project}-postgres-${var.environment}"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  storage_encrypted   = true
  kms_key_id          = var.kms_key_arn
  deletion_protection = var.environment == "prod"

  allocated_storage     = 20
  max_allocated_storage = var.max_allocated_storage
  multi_az              = var.multi_az
  apply_immediately     = true

  db_name  = "cloudmart"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name
  parameter_group_name = aws_db_parameter_group.postgres.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project}-postgres-final-${var.environment}" : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name        = "${var.project}-postgres-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}
