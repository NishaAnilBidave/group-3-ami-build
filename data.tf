data "aws_vpc" "Group_3" {
  filter {
    name   = "tag:Name"
    values = ["vpc_group3"]
  }
}

data "aws_subnet" "private_blue" {
  filter {
    name   = "tag:Name"
    values = ["private_a"]
  }
}

data "aws_subnet" "private_green" {
  filter {
    name   = "tag:Name"
    values = ["private_b"]
  }
}
