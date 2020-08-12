variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "aws_lb_target_group_arn" {
  description = "The target group arn"
  type        = string
}

variable "db_host" {
  description = "The database host name"
  type        = string

}
variable "db_user" {
  description = "The username to connect to the DB"
  type        = string

}
variable "db_password" {
  description = "The password to connect to the DB"
  type        = string
}

variable "db_name" {
  description = "The name of the DB"
  type        = string
}