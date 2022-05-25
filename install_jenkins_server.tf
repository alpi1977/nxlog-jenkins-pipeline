provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "tf-ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "tf-jenkins-server" {
  ami           = data.aws_ami.tf-ami.id
  instance_type = "t2.micro"
  key_name      = "NorthVirginia"
  //  Write your pem file name
  security_groups = ["jenkins-server-sec-gr"]
  tags = {
    Name = "Jenkins Server"
  }
  user_data = file("install-jenkins-server.sh")

  provisioner "file" {
    source      = "~/.ssh/NorthVirginia.pem" # This should be your pem file name and in the correct directory
    destination = "/home/ec2-user/NorthVirginia.pem" # This pem file should be same with the name of your pem file
  }

  provisioner "file" {
    source      = "~/.aws" # This should be the local directory where your aws credentials exist. 
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
echo Sleeping for 180 seconds and waiting Jenkins Server to be alive!
sleep 180
echo ""
echo ""
echo "Jenkins Server Initial Password is:"
echo "----------------------------------"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo ""
EOF
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/NorthVirginia.pem") # This should be your pem file name and in the correct directory
  }

}

resource "aws_security_group" "jenkins-server-sec-gr" {
  name = "jenkins-server-sec-gr"
  tags = {
    Name = "jenkins-server-sec-group"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "jenkins-server" {
  value = "http://${aws_instance.tf-jenkins-server.public_ip}:8080"
}