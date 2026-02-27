variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
}

# key_path - the path to the public key file on your local machine. For example, if you have a public key file named "my_key.pub" located in the "~/.ssh/" directory, you would set the key_path variable to "~/.ssh/my_key.pub".
variable "key_pairs" {
  type = map(object({
    key_pair_name = string
    key_path      = string
  }))
  description = "key pair names and key locations"
}

variable "ec2_config" {
  type = map(object({
    instance_type = string
  }))
  description = "EC2 instance configuration"
}

