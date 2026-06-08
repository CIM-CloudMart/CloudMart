environment                 = "prod"
region                      = "ap-south-1"
vpc_cidr                    = "10.20.0.0/16"
kubernetes_version          = "1.30"
use_fargate                 = true
desired_node_count          = 0
node_instance_type          = "t3.micro"
team                        = "team-axel"
single_nat_gateway          = true
enable_guardduty            = true
backup_retention_period = 1

