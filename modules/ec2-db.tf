resource "aws_instance" "ec2-db" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = "t2.micro"
  key_name               = "3-tier-demo"
  subnet_id              = aws_subnet.private.[count.index]id
  vpc_security_group_ids = [aws_security_group.allow_tls_db.id]
  count                  = 2
  user_data              = local.db_user_data

  tags = { name = "Db Server" }
}

output "instance_ip_addr" {
  value = aws_instance.db.private_ip[0]
}