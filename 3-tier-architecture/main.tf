
#VPC, Subnets, and EIP
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id #quick note: if you are ever reffering to something, its, resource_name.local_name.id
  cidr_block        = var.cidr[count.index]
  availability_zone = var.az[count.index]
  count             = 2

  tags = {
    Name = "public-sub" #this is proper formatting. I will adhere to one-line, henceforth, as it fits my specific use-case.
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-private-subnet[count.index] #"10.0.3.0/24"
  availability_zone = var.az[count.index]                  #"eu-west-1"
  count             = 2

  tags = { Name = "private-sub" }
}

data "aws_subnets" "sid" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
  tags = { Tier = "Public" }
}

resource "aws_eip" "myeip" {
  vpc = true
}

#Security Groups

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS ingress traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "allow_tls" }
}

resource "aws_security_group" "allow_tls_db" {
  name        = "allow_tls_db"
  description = "Allow TLS ingress traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 3306 #default port for MySQL
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "allow_tls_db" }
}

#EC2 configurations

module "ec2-db" {
  source = "./modules/ec2-db"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.app_ami.id
  instance_type               = "t2.micro"
  key_name                    = "3-tier-demo"
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  associate_public_ip_address = true
  count                       = 2
  user_data                   = local.user_data
  tags                        = { name = "Webserver" }



  provisioner "file" {
    source      = "./3-tier-demo.pem"
    destination = "/home/ec2-user/3-tier-demo.pem"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("./3-tier-demo.pem")
    }
  }
}



#Internet Gateway and such
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "main" }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "Nat-gw" }
  depends_on    = [aws_internet_gateway.gw] #good to do this explictly.
}

#Route Table https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0./0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "MyRoute" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rtb.id
  count          = 2
}

resource "aws_default_route_table" "dfltrtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id


  route {
    cidr_block = "0.0.0.0./0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = { Name = "Default-Route-tb" }
}

#config ALB
resource "aws_lb" "alb" {
  name                       = "3-tier-demo-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_tls.id]
  subnets                    = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false
  tags                       = { Environment = "test" }
}

resource "aws_lb_target_group" "albtg" {
  name        = "3-tier-demo-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 80
  }
}

resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
  count            = 2
}

resource "aws_lb_listener" "albl" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albtg.arn
  }
}

##ROUTE53 config
resource "aws_route53_zone" "main" {
  name = var.domain_name #partial config, enter this as "example.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
#very simple alias record to point the main domain name to the ALB. To understand this more, reflect on NS. The NS refers to the apex. 
#This record routes a subdomain "www" to NS.
