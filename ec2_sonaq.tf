locals {
  sonaq_key = "sonaq"
}


#  create  security group
resource "aws_security_group" "sonaq_sg" {
  name        = "${local.sonaq_key}_sg"
  description = "Allow 9000 from internet, 22 from internet"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    project_name = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_9000_ipv4_sonaq" {
  security_group_id = aws_security_group.sonaq_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_sonaq" {
  security_group_id = aws_security_group.sonaq_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_sonaq" {
  security_group_id = aws_security_group.sonaq_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "sonaq" {
  ami           = local.ubuntu_ami_id
  instance_type = var.ec2_config[local.sonaq_key]["instance_type"]
  key_name      = aws_key_pair.keys[local.sonaq_key].key_name
  subnet_id     = aws_subnet.public.id



  vpc_security_group_ids = [
    aws_security_group.sonaq_sg.id
  ]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name         = "${local.sonaq_key}-server"
    project_name = local.project_name
  }
}

# elastic ip for sonaq server
resource "aws_eip" "sonaq_eip" {
  domain = "vpc"
  tags = {
    Name         = "${local.sonaq_key}-eip"
    project_name = local.project_name
  }
}

# associate elastic ip with sonaq server
resource "aws_eip_association" "sonaq_eip_assoc" {
  instance_id   = aws_instance.sonaq.id
  allocation_id = aws_eip.sonaq_eip.id
}


