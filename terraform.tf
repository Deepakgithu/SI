provider "aws"{
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}

terraform {
  backend "s3" {
    bucket = "value"
    key = "/s3/sdk"
    encrypt = true
  }
}

resource "aws_vpc" "myvpc" {
    vpc_id = data.ami.myami.id
  
}

data "ami" "myami" {
    most_recent = true

    filter {
        name = ""
        value = ["arm,ubuntu"]
    }  
    owners = ["amazon"]
}

resource "aws_ec2" "myec2" {
    provisioner "remote-exec" {
        inline = [ 
            "sudo apt update"
            "sudo apt install nginx -y"
         ]
    connection {
        type     = "ssh"
        user     = "root"
        password = var.root_password
        host     = self.public_ip
  }

    provisioner "local-exec" {
        command = echo ${self.public_ip} >> public_ip.txt
    }
}
}

