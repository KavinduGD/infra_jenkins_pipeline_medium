vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"


ec2_config = {
  jenkins = {
    instance_type = "t2.medium"
  }
  sonaq = {
    instance_type = "t2.medium"
  }
  depl = {
    instance_type = "t2.medium"
  }
}

key_pairs = {
  jenkins = {
    key_pair_name = "jenkins-key"
    key_path      = "~/.ssh/todo_jenkins_key.pub"
  }
  sonaq = {
    key_pair_name = "sonaq-key"
    key_path      = "~/.ssh/todo_sonaq_key.pub"
  }
  depl = {
    key_pair_name = "depl-key"
    key_path      = "~/.ssh/todo_depl_key.pub"
  }
}

