resource "aws_vpc" "sd_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Stack Dependency VPC"
  }
}

resource "aws_subnet" "sd_subnet" {
    vpc_id = aws_vpc.sd_vpc.id
    cidr_block = "10.0.0.0/16"
    map_public_ip_on_launch = "true"

    tags = {
        demo = "Stack Dependency Subnet"
    }
}