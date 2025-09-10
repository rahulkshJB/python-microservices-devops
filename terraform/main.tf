# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a security group to allow HTTP and SSH traffic
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 8080 # Port for the frontend service
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22 # Port for SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance [cite: 81]
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.app_sg.name]
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "DevOps Assignment Server"
  }
}

# Output the public IP of the instance
output "public_ip" {
  value = aws_instance.app_server.public_ip
}