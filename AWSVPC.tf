// Creating Provider

provider "aws"{
 region = "ap-south-1"
 profile = "paylit"
}

// Creating VPC 

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "autoVPC"
  }
}


// Creating Subnets for public world

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public_Subnet-1"
  }
}

// Creating Subnets for private Access

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Private_Subnet-1"
  }
}


// Creating Internet Gateway for connect vpc to internet
resource "aws_internet_gateway" "MyGateWay" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my_gateway"
  }
}


// Creating Routing Table for internet gateway so that instance can connect to outside world

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyGateWay.id
  }

  tags = {
    Name = "myroute"
  }
}

// Associatings subnets with public and privates 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id     = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table.id
}


// Creating Security Groups for allowing clients that use-cases

resource "aws_security_group" "mysecurity" {
  name        = "mysecurity"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
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
    Name = "Allowing_HTTP_SSH_TCP"
  }
}

// Launching EC2 Instances for public uses  that is wordpress

resource "aws_instance" "myos1" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  key_name= "taskkey"
  vpc_security_group_ids= [aws_security_group.mysecurity.id]
  subnet_id= aws_subnet.public_subnet.id
  tags = {
    Name = "WP_OS"
  }
}

// Lunching EC2 Instances for private uses that is mysql database

resource "aws_instance" "myos2" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  key_name= "taskkey"
  vpc_security_group_ids= [aws_security_group.mysecurity.id]
  subnet_id= aws_subnet.private_subnet.id
  tags = {
    Name = "MYSQL_OS"
  }
}