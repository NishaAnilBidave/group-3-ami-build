packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "blue_ami_name" {
  type    = string
  default = "Blue_Ami"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "Blue-web-server" {
  ami_name      = "${var.blue_ami_name}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  
  vpc_filter {
    filters = {
      "tag:Name" : "vpc_group3"
      isDefault = "false"
      cidr      = "172.168.0.0/16"
    }
  }
  subnet_filter {
    filters = {
      "tag:Name" : "public_a"
    }
    most_free = true
    random = false
  }

  associate_public_ip_address = true
  
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

variable "green_ami_name" {
  type    = string
  default = "Green_Ami"
}

source "amazon-ebs" "Green-web-server" {
  ami_name      = "${var.green_ami_name}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-south-1"

  vpc_filter {
    filters = {
      "tag:Name" : "vpc_group3"
      isDefault = "false"
      cidr      = "172.168.0.0/16"
    }
  }
  subnet_filter {
    filters = {
      "tag:Name" : "public_b"
    }
    most_free = true
    random = false
  }

  associate_public_ip_address = true

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
  name = "blue-build"
  sources = [
    "source.amazon-ebs.Blue-web-server"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
    extra_arguments = ["--extra-vars", "@./c_blue.yml"]
    
  }
}

build {
  name = "green-build"
  sources = [
    "source.amazon-ebs.Green-web-server"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
    extra_arguments = ["--extra-vars", "@./c_green.yml"]

}
}
