terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-docker-ec2" {
  ami = "ami-005de95e8ff495156"
  instance_type = "t2.micro"
  key_name = "NorthVirginia"
  security_groups = ["tf-docker-sec-gr-203"]
  tags = {
    Name = "Web Server of Bookstore-Ubuntu"
  }
  user_data = <<-EOF
          #! /bin/bash
          apt-get update
          apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
          add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
          apt-get update
          apt-get install -y docker-ce
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ubuntu
          usermod -a -G docker jenkins
          curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          apt-get install git -y
          cd /home/ubuntu
          mkdir bookstore-project
          cd bookstore-project
          git init
          git remote add origin https://github.com/alpi1977/nxlog-jenkins-pipeline.git
          git fetch origin branchX
          git checkout branchX
          newgrp docker
          docker build -t aozkan1977/bookstore:latest .
          docker-compose up -d
          EOF

}


resource "aws_security_group" "tf-docker-sec-gr-203" {
  name = "tf-docker-sec-gr-203"
  tags = {
    Name = "tf-docker-sec-gr-203"
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "website" {
  value = "http://${aws_instance.tf-docker-ec2.public_dns}"

}