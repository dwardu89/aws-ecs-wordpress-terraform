resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "wordpress"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "wordpress" {
  family = "wordpress"

  container_definitions = <<EOF
[
  {
    "name": "wordpress",
    "image": "wordpress:php7.4",
    "cpu": 0,
    "memory": 512,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-2",
        "awslogs-group": "wordpress",
        "awslogs-stream-prefix": "wordpress-ecs"
      }
    },
    "portMappings": [{
      "containerPort": 80
    }],
    "environment" : [
      { "name" : "WORDPRESS_DB_HOST", "value" : "${var.db_host}" },
      { "name" : "WORDPRESS_DB_USER", "value" : "${var.db_user}" },
      { "name" : "WORDPRESS_DB_PASSWORD", "value" : "${var.db_password}" },
      { "name" : "WORDPRESS_DB_NAME", "value" : "${var.db_name}" }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "wordpress" {
  name            = "wordpress"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.wordpress.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "wordpress"
    container_port   = 80
  }
}