environment                 = "staging"
region                      = "ap-south-1"
vpc_cidr                    = "10.10.0.0/16"
kubernetes_version          = "1.31"
use_fargate                 = true
desired_node_count          = 0
node_instance_type          = "t3.micro"
team                        = "team-axel"
single_nat_gateway          = true
enable_guardduty            = false
backup_retention_period = 1

