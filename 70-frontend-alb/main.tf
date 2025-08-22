# This module creates a ingress Application Load Balancer (ALB) for the Roboshop project in public subnets.
module "ingress_alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "9.16.0"
  internal                   = false
  name                       = "${var.project}-${var.environment}-ingress-alb" #roboshop-dev-ingress-alb
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  create_security_group      = false
  security_groups            = [local.ingress_alb_sg_id]
  enable_deletion_protection = false
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-ingress-alb"
    }
  )
}

# listeners are used to define how the ALB will handle incoming traffic only on port 80 will be allowed
resource "aws_lb_listener" "ingress_alb" { #_listener_arn
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.acm_certificate_arn # must first create the acm certificate on domain name (devops84.shop)

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from ingress ALB Using HTTPS</h1>"
      status_code  = "200"
    }
  }
}


# This module creates a Global Accelerator to route traffic to the ingress ALB.
# if catalogue service traffic got to ingress ALB it goes to catalogue service
# if cart service traffic got to ingress ALB it goes to cart service
resource "aws_route53_record" "ingress_alb" {
  zone_id = var.zone_id
  name    = "${var.environment}.${var.zone_name}" # dev.devops84.shop If * is use its efforts on serial key
  type    = "A"

  alias {
    name                   = module.ingress_alb.dns_name # The DNS name of the ALB
    zone_id                = module.ingress_alb.zone_id  # The zone ID of the ALB
    evaluate_target_health = true                         # Evaluate the health of the target
  }
}