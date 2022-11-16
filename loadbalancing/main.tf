# --- loadbalancing/main.tf ---

resource "aws_lb" "project_lb" {
  name               = "project-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg]
  subnets            = tolist(var.public_subnet)

}

resource "aws_lb_target_group" "project_tg" {
  name        = "project-lb-tg-${substr(uuid(), 0, 3)}"
  protocol    = var.tg_protocol
  port        = var.tg_port
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

}
resource "aws_alb_target_group_attachment" "tg-attachment1" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = var.target_id1
}
resource "aws_alb_target_group_attachment" "tg-attachment2" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = var.target_id2
}
resource "aws_alb_target_group_attachment" "tg-attachment3" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = var.target_id3
}


resource "aws_lb_listener" "project_lb_listener" {
  load_balancer_arn = aws_lb.project_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_tg.arn
  }
}