output "instance_public_ip" {
  value = aws_instance.lostfound_ec2.public_ip
}

output "instance_public_dns" {
  value = aws_instance.lostfound_ec2.public_dns
}
