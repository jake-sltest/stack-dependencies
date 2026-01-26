resource "aws_instance" "infracost_test_instance" {
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "m3.xlarge" # <<<<<<<<<< Try changing this to m5.xlarge to compare the costs

  tags = {
    Name        = "infracost-test-instance"
    Environment = "production"
    Service     = "web-app"
  }

  root_block_device {
    volume_size = 1000 # <<<<<<<<<< Try adding volume_type="gp3" to compare costs
  }
}

resource "aws_lambda_function" "infracost_test_function" {
  runtime       = "nodejs12.x"
  handler       = "exports.test"
  image_uri     = "test"
  function_name = "infracost-test-function"
  role          = "arn:aws:ec2:us-east-1:123123123123:instance/i-1231231231"
  memory_size   = 512

  tags = {
    Environment = "Prod"
  }
}

resource "aws_db_instance" "infracost_test_db" {
  engine               = "mysql"
  engine_version       = "5.7.44"
  instance_class       = "db.c5.2xlarge"
  allocated_storage    = 20
  db_name              = "exampledb"
  username             = "admin"
  password             = "testpassword123"
  skip_final_snapshot  = true
  deletion_protection  = false

  tags = {
    Name = "infracost-test-db"
  }
}
