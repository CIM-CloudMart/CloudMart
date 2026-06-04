# ==================== RDS PostgreSQL Module ====================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group-${var.environment}"
  subnet_ids = var.private_data_subnet_ids
}

# Read latest secret version for credentials
data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg-${var.environment}"
  vpc_id      = var.vpc_id
  description = "Security group for RDS PostgreSQL"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_cluster_sg_id]
    description     = "Allow PostgreSQL from EKS (Fargate pods or worker nodes)"
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
  engine_version = var.engine_version
  instance_class = var.instance_class

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  allocated_storage     = 20
  max_allocated_storage = var.max_allocated_storage
  multi_az              = var.multi_az

  db_name  = "cloudmart"
  username = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"]

  db_subnet_group_name   = aws_db_subnet_group.main.name

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
