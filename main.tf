provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu_sg"
  description = "Allow various incoming traffic"

  dynamic "ingress" {
    for_each = [80, 22, 443, 10050, 51830, 3306, 8000, 8080, 9090, 9091, 9093, 3000, 9100]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.micro"
  count         = 1

  key_name      = "terraform-key"
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    sudo apt install unzip
    apt install -y docker.io docker-compose
    usermod -aG docker $USER
    usermod -aG docker ubuntu
    # Additional setup if required
    sudo mkdir new_project 
    sudo cd new_project 
    sudo touch docker-compose.yml
    sudo reboot

    EOF

  tags = {
    Name = "ubuntu-${count.index + 1}"
  }
}


output "public_ips" {value = aws_instance.ubuntu[*].public_ip}

output "ssh_commands" {value = [for ip in aws_instance.ubuntu[*].public_ip : "ssh -i 'terraform-key.pem' ubuntu@ec2-${replace(ip, ".", "-")}.eu-central-1.compute.amazonaws.com"]}

#terraform apply -auto-approve
#terraform destroy -auto-approve
#find . -name "terraform.tfstate.lock.info" -type f