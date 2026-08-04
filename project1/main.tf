# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "publicsubnet1"{
vpc_id = aws_vpc.myvpc.id
cidr_block = var.publicsubnet1
availability_zone = "us-west-2a"
map_public_ip_on_launch = true
tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "publicsubnet2"{
vpc_id = aws_vpc.myvpc.id
cidr_block = var.publicsubnet2
availability_zone = "us-west-2b"
map_public_ip_on_launch = true
tags = {
    Name = "public-subnet2"
  }
}

#create internetgateway
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygateway"
  }
}

#route table for public subnet
resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }
}

#route_table attachment to public subnet
resource "aws_route_table_association" "myRTassociation1" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_route_table_association" "myRTassociation2" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.myRT.id
}

#create security Group
resource "aws_security_group" "mySG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from terminal"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

#create ec2
resource "aws_instance" "web-server1" {
  ami           = "ami-0e0d2e3754385cbd3"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.publicsubnet1.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "webserver1"
  }
}

resource "aws_instance" "web-server2" {
  ami           = "ami-0e0d2e3754385cbd3"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.publicsubnet2.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name = "webserver2"
  }
}

#create alb
resource "aws_lb" "myLB" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.publicsubnet1.id,aws_subnet.publicsubnet2.id]

  tags = {
    Environment = "Dev"
  }
}

#create TG
resource "aws_lb_target_group" "myTG" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#Registering Targetgroups
resource "aws_lb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.myTG.arn
  target_id        = aws_instance.web-server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.myTG.arn
  target_id        = aws_instance.web-server2.id
  port             = 80
}

#Add listners to ALB

resource "aws_lb_listener" "myLB" {
  load_balancer_arn = aws_lb.myLB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.myTG.arn
        weight = 100
      }
    }
  }
}

output "loadbalancerdns" {
  value       = aws_lb.myLB.dns_name
  description = "description"
}


