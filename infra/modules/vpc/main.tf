# ==================== VPC & 3-Tier Networking ====================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-vpc-${var.environment}"
  }
}

# ==================== Subnets (3-Tier Design) ====================

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = "${var.region}${element(["a", "b"], count.index)}"

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${element(["a", "b"], count.index)}-${var.environment}"
    Tier = "public"
  }
}

# Private App Subnets (for EKS Worker Nodes)
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = "${var.region}${element(["a", "b"], count.index)}"

  tags = {
    Name                              = "${var.project}-private-app-${element(["a", "b"], count.index)}-${var.environment}"
    Tier                              = "private-app"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private Data Subnets (for RDS, DynamoDB endpoints)
resource "aws_subnet" "private_data" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = "${var.region}${element(["a", "b"], count.index)}"

  tags = {
    Name = "${var.project}-private-data-${element(["a", "b"], count.index)}-${var.environment}"
    Tier = "private-data"
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
  count  = 1
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project}-nat-${var.environment}"
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
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.project}-private-app-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Private Data Route Table (same as private app)
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.project}-private-data-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "private_data" {
  count          = 2
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-endpoints-sg-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_app.id, aws_route_table.private_data.id]

  tags = {
    Name = "${var.project}-dynamodb-endpoint-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private_app[*].id
  security_group_ids = [aws_security_group.endpoints_sg.id]

  tags = {
    Name = "${var.project}-sqs-endpoint-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_app.id, aws_route_table.private_data.id]

  tags = {
    Name = "${var.project}-s3-endpoint-${var.environment}"
  }
}
