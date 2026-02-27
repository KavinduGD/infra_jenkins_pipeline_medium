locals {
  jenkins_key = "jenkins"
}


#  create  security group
resource "aws_security_group" "jenkins_sg" {
  name        = "${local.jenkins_key}_sg"
  description = "Allow 8080 from internet, 22 from internet"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    project_name = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4_jenkins" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}



resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_jenkins" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_jenkins" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "jenkins" {
  ami           = local.ubuntu_ami_id
  instance_type = var.ec2_config[local.jenkins_key]["instance_type"]
  key_name      = aws_key_pair.keys[local.jenkins_key].key_name
  subnet_id     = aws_subnet.public.id


  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id,
  ]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name         = "${local.jenkins_key}-server"
    project_name = local.project_name
  }

}

# elastic ip for jenkins server
resource "aws_eip" "jenkins_eip" {
  domain = "vpc"
  tags = {
    Name         = "${local.jenkins_key}-eip"
    project_name = local.project_name
  }
}

# associate elastic ip with jenkins server
resource "aws_eip_association" "jenkins_eip_association" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins_eip.id
}

