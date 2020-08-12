module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "wordpress" {
  name        = "wordpress"
  description = "Wordpress Security Group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow http "
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_sg"
  }
}


resource "aws_security_group" "database" {
  name        = "database"
  description = "Database Security Group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = ["${aws_security_group.wordpress.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "database_sg"
  }
}


resource "aws_lb" "lb" {
  name               = "wp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wordpress.id, module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false 


  tags = {
    Environment = local.environment
  }
}
resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

resource "aws_lb_target_group" "wordpress" {
  name     = "wordpress-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
  matcher = "200-299,302"
  }
}
