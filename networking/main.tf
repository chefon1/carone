# --- networking/main.tf ---

resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_vpc"
  }
}

resource "aws_subnet" "project_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "project_public_assoc" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.project_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.project_public_rt.id
}

resource "aws_subnet" "project_private_subnet" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_private_${count.index + 1}"
  }
}

resource "aws_route_table_association" "project_private_assoc" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.project_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.project_private_rt.id
}

resource "aws_internet_gateway" "project_internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "project_eip" {

}

resource "aws_nat_gateway" "project_natgateway" {
  allocation_id = aws_eip.project_eip.id
  subnet_id     = aws_subnet.project_public_subnet[1].id
}

resource "aws_route_table" "project_public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_public"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.project_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_internet_gateway.id
}

resource "aws_route_table" "project_private_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "04NSOC.SUPP.0000.NSV-project_private"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.project_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.project_natgateway.id
}



resource "aws_security_group" "alb_sg" {
  name        = "project_web_sg"
  description = "Allow all inbound HTTP traffic"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow traffic inside ALB security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    description     = ""
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}