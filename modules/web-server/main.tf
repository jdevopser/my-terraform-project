data "aws_ami" "amazon-2-latest" {
  owners      = ["amazon"]
  most_recent = true

  filter {

    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "my-server-key" {
  key_name   = "my-server-key.pem"
  public_key = file("/home/tarik/.ssh/my-server-key.pem.pub")
}

resource "aws_security_group" "allow-ssh-web" {
  name = "allow-ssh-web"

  vpc_id = var.vpc_id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]

  }

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Allow-ssh-web"
  }
}

resource "aws_instance" "my-server" {
  ami             = data.aws_ami.amazon-2-latest.id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  key_name        = aws_key_pair.my-server-key.key_name
  security_groups = [aws_security_group.allow-ssh-web.id]

  user_data = file("./myscript.sh")

  tags = {
    "Name" = "${var.environment}-my-server"
  }

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/tarik/.ssh/my-server-key.pem")
    host = self.public_ip
  }

   
  provisioner "remote-exec" {

      inline = [
        "sudo yum update -y", "sudo yum install docker -y","sudo systemctl start docker","sudo docker run -d -p 80:80 nginx "
      ]
    
}

}