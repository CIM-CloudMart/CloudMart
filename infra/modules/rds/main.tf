# ==================== RDS PostgreSQL Module ====================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group-${var.environment}"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg-${var.environment}"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]   # Only allow from EKS nodes
    description     = "Allow PostgreSQL from EKS worker nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg-${var.environment}"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project}-postgres-${var.environment}"
  engine         = "postgres"
  engine_version = "16.3"
  instance_class = var.environment == "prod" ? "db.t3.small" : "db.t3.micro"

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  allocated_storage    = 20
  max_allocated_storage = 100
  multi_az             = var.environment == "prod"

  db_name  = "cloudmart"
  username = "cloudmartadmin"
  manage_master_user_password = true   # AWS managed password (secure)

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project}-postgres-final-${var.environment}" : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
