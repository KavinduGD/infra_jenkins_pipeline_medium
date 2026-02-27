# create a key pair
resource "aws_key_pair" "keys" {

  for_each = var.key_pairs

  key_name   = each.value.key_pair_name
  public_key = file(each.value.key_path)
}
