module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.2.2"

  create_lb = true

  name            = "${local.cluster_name}-ingress-alb"

  security_groups = var.infra_public_security_group_ids
  enable_http2    = false

  subnets         = var.public_subnets_id
  tags            = var.tags
  vpc_id          = var.vpc_id

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      certificate_arn    = module.acm.acm_certificate_arn
      port               = 443
      target_group_index = 1
      ssl_policy         = var.ssl_policy
    }
  ]

  target_groups = [
    {
      "name"                 = "${var.platform_name}-infra-alb-https"
      "backend_port"         = "32443"
      "backend_protocol"     = "HTTPS"
      "deregistration_delay" = "20"
      "health_check_matcher" = "404"
    },
  ]
  idle_timeout  = 500
  access_logs = {
    bucket = "prod-s3-elb-logs-eu-central-1"
  }
}

module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "2.10.2"
}