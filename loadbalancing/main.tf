#For the main.tf file here, we will simply create the load balancer, target group, and listener. Note that the load balancer lies in the public subnet layer. I also made sure to specify that the load balancer depend on the autoscaling group it is associated with, so that health checks were not failed.

# --- loadbalancing/main.tf ---


# INTERNET FACING LOAD BALANCER

resource "aws_lb" "three_tier_lb" {
  name            = "three-tier-loadbalancer"
  security_groups = [var.lb_sg]
  subnets         = var.public_subnets
  idle_timeout    = 400

  depends_on = [
    var.app_asg
  ]
}

resource "aws_lb_target_group" "three_tier_tg" {
  name     = "three-tier-lb-tg-${var.http_listener_port}"
  port              = var.http_listener_port
  protocol          = var.http_listener_protocol
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "three_tier_lb_listener" {
  load_balancer_arn = aws_lb.three_tier_lb.arn
  port              = var.http_listener_port
  protocol          = var.http_listener_protocol
#    default_action {
#      type             = "forward"
#      target_group_arn = aws_lb_target_group.three_tier_tg.arn
#    }
  default_action {
    type = "redirect"

    redirect {
      port        = var.https_listener_port
      protocol    = var.https_listener_protocol
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.three_tier_lb.arn
  port              = var.https_listener_port
  protocol          = var.https_listener_protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three_tier_tg.arn
  }
}

