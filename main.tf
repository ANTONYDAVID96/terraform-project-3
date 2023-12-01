resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "tfsn1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
  tags = {
    Name = "sn1"
  }
}
resource "aws_subnet" "tfsn2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
 availability_zone = "us-east-1b"
  tags = {
    Name = "sn2"
  }
}
resource "aws_internet_gateway" "tfigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "demoigw"
  }
}
resource "aws_route_table" "tfpubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfigw.id
  }

  tags = {
    Name = "demopubrt"
  }
}
resource "aws_route_table_association" "tfrtassosn1" {
  subnet_id      = aws_subnet.tfsn1.id
  route_table_id = aws_route_table.tfpubrt.id
}
resource "aws_route_table_association" "tfrtassosn2" {
  subnet_id      = aws_subnet.tfsn2.id
  route_table_id = aws_route_table.tfpubrt.id
}
resource "aws_security_group" "allow_tfsg" {
  name        = "allow_tdsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "SHH"
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
    Name = "allow_TFSG"
  }
}

resource "aws_s3_bucket" "mybuck" {
  bucket = "todaydemobucketbro"
}

resource "aws_instance" "pub_ins" {
  ami                          = "ami-0fc5d935ebf8bc"
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.tfsn1.id
  vpc_security_group_ids       = [aws_security_group.allow_tfsg.id]
  key_name                     = "David"
  associate_public_ip_address  =  "true"
  user_data                    = base64encode(file("userdata.sh"))
  tags = {
    Name = "aws_terraform-Ins"
  }
}
