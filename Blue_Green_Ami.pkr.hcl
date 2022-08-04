packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix1" {
  type    = string
  default = "Blue_Ami"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix1}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  vpc_id        = "vpc-0e4a12ff878f00312"
  subnet_id     = "subnet-0973eb0379fbbe882"
  security_group_id = "sg-0993a9913a37d35be"
  // ssh_interface = "private_ip"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

variable "ami_prefix2" {
  type    = string
  default = "Green_Ami"
}

source "amazon-ebs" "ubuntu-focal" {
  ami_name      = "${var.ami_prefix2}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  vpc_id        = "vpc-0e4a12ff878f00312"
  subnet_id     = "subnet-045108be0ce6eb6aa"
  security_group_id = "sg-0993a9913a37d35be"  
  // ssh_interface = "private_ip"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
    extra_arguments = ["--extra-vars", "@/c_blue.yml"]
  }
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu-focal"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
    extra_arguments = ["--extra-vars", "@/c_green.yml"]
  }

}