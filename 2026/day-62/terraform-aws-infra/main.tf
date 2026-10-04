# ============================================================
# Day 62 - Providers, Resources and Dependencies
# AWS Networking Stack
# ============================================================

# ------------------------------------------------------------
# 1. VPC
# ------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

# ------------------------------------------------------------
# 2. Public Subnet
# ------------------------------------------------------------
# ap-south-1a is used because t2.micro was not supported
# in ap-south-1c in the previous attempt.

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# ------------------------------------------------------------
# 3. Internet Gateway
# ------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

# ------------------------------------------------------------
# 4. Public Route Table
# ------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "TerraWeek-Public-RT"
  }
}

# ------------------------------------------------------------
# 5. Route Table Association
# ------------------------------------------------------------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------
# 6. Security Group
# ------------------------------------------------------------

resource "aws_security_group" "main" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

# ------------------------------------------------------------
# 7. EC2 Instance
# ------------------------------------------------------------

resource "aws_instance" "main" {
  ami           = "ami-0351a972f17e4d123"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  associate_public_ip_address = true

  monitoring = false

  tags = {
    Name = "TerraWeek-Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------
# 8. S3 Bucket
# ------------------------------------------------------------
# The bucket has an explicit dependency on the EC2 instance.
# This demonstrates Terraform's depends_on functionality.

resource "aws_s3_bucket" "logs" {
  bucket = "terrawweek-logs-avinash-2026"

  depends_on = [
    aws_instance.main
  ]

  tags = {
    Name = "TerraWeek-Application-Logs"
  }
}
