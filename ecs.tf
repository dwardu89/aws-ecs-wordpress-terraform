module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = local.name
}


module "ec2-profile" {
  source = "./module/ecs-instance-profile"
  name   = local.name
}



module "wordpress" {
  source                  = "./service-wordpress"
  cluster_id              = module.ecs.this_ecs_cluster_id
  aws_lb_target_group_arn = aws_lb_target_group.wordpress.arn

  db_host     = module.db.this_db_instance_endpoint
  db_user     = local.db_user
  db_password = local.db_password
  db_name     = local.db_name
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = local.ec2_resources_name

  # Launch configuration
  lc_name = local.ec2_resources_name

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  security_groups      = [module.vpc.default_security_group_id, aws_security_group.database.id, aws_security_group.wordpress.id]
  iam_instance_profile = module.ec2-profile.this_iam_instance_profile_id
  user_data            = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = local.ec2_resources_name
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = file("templates/user-data.sh")

  vars = {
    cluster_name = local.name
  }
}
