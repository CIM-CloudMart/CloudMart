# ==================== VPC & Multi-AZ 3-Tier Networking ====================

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.az_count
  cluster_name      = coalesce(var.cluster_name, "${var.project}-eks-${var.environment}")
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name = "${var.project}-vpc-${var.environment}"
    }, tomap({
      Project     = var.project
      Environment = var.environment
      Team        = var.team
  }))
}

# ==================== Subnets (3-Tier Design) ====================

# Public Subnets
locals {
  newbits = var.subnet_prefix_length - var.vpc_cidr_prefix
}

resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name                                          = "${var.project}-public-${count.index + 1}-${var.environment}"
    Tier                                          = "public"
    Project                                       = var.project
    Environment                                   = var.environment
    Team                                          = var.team
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# Private App Subnets (for EKS Worker Nodes)
resource "aws_subnet" "private_app" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                          = "${var.project}-private-app-${count.index + 1}-${var.environment}"
    Tier                                          = "private-app"
    Project                                       = var.project
    Environment                                   = var.environment
    Team                                          = var.team
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# Private Data Subnets (for RDS, DynamoDB endpoints)
resource "aws_subnet" "private_data" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index + var.az_count * 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project}-private-data-${count.index + 1}-${var.environment}"
    Tier        = "private-data"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

# ==================== Internet Gateway & NAT ====================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw-${var.environment}"
  }
}

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project}-nat-${count.index + 1}-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

# ==================== Route Tables ====================

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-public-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table
resource "aws_route_table" "private_app" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
  }

  tags = {
    Name        = "${var.project}-private-app-rt-${count.index + 1}-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

resource "aws_route_table_association" "private_app" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private Data Route Table (same as private app)
resource "aws_route_table" "private_data" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
  }

  tags = {
    Name        = "${var.project}-private-data-rt-${count.index + 1}-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

resource "aws_route_table_association" "private_data" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data[count.index].id
}

# ==================== VPC Endpoints & Security Groups ====================

resource "aws_security_group" "endpoints_sg" {
  name        = "${var.project}-endpoints-sg-${var.environment}"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow HTTPS only within the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "${var.project}-endpoints-sg-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)

  tags = {
    Name = "${var.project}-dynamodb-endpoint-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project}-secretsmanager-endpoint-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private_app[*].id, aws_route_table.private_data[*].id)

  tags = {
    Name = "${var.project}-s3-endpoint-${var.environment}"
  }
}

# ==================== Bastion Host & Security Group ====================

resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-sg-${var.environment}"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  # Ingress is empty since we are using AWS Systems Manager (SSM) Session Manager for shell access.
  # No public port 22 is exposed to the internet.

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-bastion-sg-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role" "bastion" {
  name = "${var.project}-bastion-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project}-bastion-profile-${var.environment}"
  role = aws_iam_role.bastion.name
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 enforced
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = "${var.project}-bastion-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}
