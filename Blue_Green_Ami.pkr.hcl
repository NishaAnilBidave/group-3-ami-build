packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "Blue_Ami"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  vpc_id        = "vpc-0e4a12ff878f00312"
  subnet_id     = "subnet-0973eb0379fbbe882"
  // instance_name   = "i-0c007c06e4e000c05"
  security_group_id = "sg-0993a9913a37d35be"
  // ssh_interface = "private_ip"
  // ssh_keypair_name = "Blue_ami"
  // ssh_private_key_file = "Blue_ami.pem"
  // ssh_clear_authorized_keys = true
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

source "amazon-ebs" "ubuntu-focal" {
  ami_name      = "Green_Ami"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  vpc_id        = "vpc-0e4a12ff878f00312"
  subnet_id     = "subnet-045108be0ce6eb6aa"
  // instance_id   = "i-0b5f5c3b83caa36d6"
  security_group_id = "sg-0993a9913a37d35be"  
  // ssh_interface = "private_ip"
  // ssh_keypair_name = "Green_ami"
  // ssh_private_key_file = "Green_ami.pem"
  // ssh_clear_authorized_keys = true
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
    "source.amazon-ebs.ubuntu",
    "source.amazon-ebs.ubuntu-focal"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
  }

}