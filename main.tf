provider "aws" {
  access_key = "******************"
  secret_key = "******************"
  region = "ap-southeast-1"
}

resource "aws_security_group" "new-group" {
  name = "new-group"
  description = "Web Security Group"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "new-group" {
  ami = "ami-0d06583a13678c938"
  instance_type = "t2.micro"
  key_name = "lseg"
  security_groups = ["${aws_security_group.new-group.name}"]
}

resource "aws_s3_bucket" "b" {
  bucket = "zip-upload-storage"
  acl    = "private"

  tags = {
    Name        = "My bucket janith"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "ddbtable" {
  name             = "script_log"
  hash_key         = "timestamp"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  attribute {
  name = "timestamp"
  type = "S"
  }

  
}