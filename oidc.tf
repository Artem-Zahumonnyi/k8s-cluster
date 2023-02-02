resource "aws_eks_identity_provider_config" "keycloak" {
  count = local.create_eks_identity_provider ? 1 : 0

  cluster_name = var.platform_name

  oidc {
    client_id                     = var.client_id
    groups_claim                  = var.groups_claim
    identity_provider_config_name = var.identity_provider_config_name
    issuer_url                    = var.issuer_url
  }

  tags = local.tags
}
