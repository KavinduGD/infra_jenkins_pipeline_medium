locals {
  depl_key = "depl"
}


#  create  security group
# 3000 - for the jenkins server to send http web hook request to web hook server
# 4000 - access the application from the internet
# 22 - for ssh access to the server 
resource "aws_security_group" "depl_sg" {
  name        = "${local.depl_key}_sg"
  description = "Allow 3000 from jenkins server,22 and 4000 from internet"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    project_name = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_3000_ipv4_depl" {
  security_group_id            = aws_security_group.depl_sg.id
  referenced_security_group_id = aws_security_group.jenkins_sg.id
  from_port                    = 3456
  to_port                      = 3456
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_4000_ipv4_depl" {
  security_group_id = aws_security_group.depl_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 4000
  to_port           = 4000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_depl" {
  security_group_id = aws_security_group.depl_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_depl" {
  security_group_id = aws_security_group.depl_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "depl" {

  ami           = local.ubuntu_ami_id
  instance_type = var.ec2_config[local.depl_key]["instance_type"]
  key_name      = aws_key_pair.keys[local.depl_key].key_name
  subnet_id     = aws_subnet.public.id



  vpc_security_group_ids = [
    aws_security_group.depl_sg.id
  ]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name         = "${local.depl_key}-server"
    project_name = local.project_name
  }
}

# elastic ip for depl server
resource "aws_eip" "depl_eip" {
  domain = "vpc"
  tags = {
    Name         = "${local.depl_key}-eip"
    project_name = local.project_name
  }
}

# associate elastic ip with depl server
resource "aws_eip_association" "depl_eip_assoc" {
  instance_id   = aws_instance.depl.id
  allocation_id = aws_eip.depl_eip.id
}


