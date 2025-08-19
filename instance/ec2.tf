# This script will run instance & security Group inbound rules & ourbound rules 
resource "aws_instance" "K8" {
  ami           = "ami-09c813fb71547fc4f"
  instance_type = "t3.micro" # Instance type, can be changed as needed
  vpc_security_group_ids = [aws_security_group.allow_all_K8.id] # Security Group ID

  root_block_device {
    volume_size = 50 # Size of the root volume in GB
    volume_type = "gp3" # or "gp2", depending on your preference
  }

    user_data = file("docker.sh") # User data script to install K8
  tags = { # Tags for the instance
    Name = "K8" # Name of the instance
  }
}
resource "aws_security_group" "allow_all_K8" {
    name        = "allow_all_K8"
    description = "allow all traffic"

    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "allow-all-K8"
    }
}