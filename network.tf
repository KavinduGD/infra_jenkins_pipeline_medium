# VPC 
resource "aws_vpc" "todo_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name         = "todo_vpc"
    project_name = local.project_name
  }
}

# Internet gateway to internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.todo_vpc.id

  tags = {
    project_name = local.project_name
    Name         = "todo-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# public subnet for ec2 instances
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.todo_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name         = "public_subnet"
    project_name = local.project_name
  }
}

# route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.todo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name         = "public-route-table"
    project_name = local.project_name
  }
}

#  associate public subnet with route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
