# Enterprise Infrastructure Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# High Availability Configuration
resource "aws_autoscaling_group" "enterprise_asg" {
  name                = "enterprise-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.enterprise_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 3
  max_size         = 10
  desired_capacity = 5

  tag {
    key                 = "Name"
    value               = "enterprise-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Load Balancer for High Availability
resource "aws_lb" "enterprise_lb" {
  name               = "enterprise-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
    Purpose     = "enterprise-load-balancing"
  }
}
