output "aws_instance_ip" {
  description = "IP of the ec2 instance"
  value       = aws_instance.sd_instance.public_ip
}