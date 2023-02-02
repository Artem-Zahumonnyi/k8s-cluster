locals {
  tags = merge(
    var.tags,
    {
      "user:tag" = var.platform_name
    },
  )
  create_eks                   = false
  create_alb                   = true
  create_eks_identity_provider = false
}