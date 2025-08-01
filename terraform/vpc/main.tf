resource "aws_default_vpc" "sd_vpc" {
  tags = {
    Name = "Stack Dependency VPC"
  }
}

resource "aws_subnet" "sd_subnet" {
  vpc_id                  = aws_default_vpc.sd_vpc.id
  map_public_ip_on_launch = "true"

  tags = {
    demo = "Stack Dependency Subnet"
  }
}
