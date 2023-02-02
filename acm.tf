data "aws_route53_zone" "this" {
  name         = var.platform_domain_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "${var.platform_name}.${var.platform_domain_name}",
    "*.${var.platform_name}.${var.platform_domain_name}",
  ]

  tags = merge(local.tags, tomap({ "Name" = var.platform_name }))
}