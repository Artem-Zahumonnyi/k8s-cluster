variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.23"
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::093899590031:role/EKSDeployerRole)"
  type        = string
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone for platform"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "private_subnets_id" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
  type        = list(any)
}

variable "public_subnets_id" {
  description = "A list of subnets to place the LB and other external resources"
  type        = list(any)
}

variable "ssl_policy" {
  description = "Predefined SSL security policy for ALB https listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "infra_public_security_group_ids" {
  description = "Security group IDs should be attached to external ALB"
  type        = list(any)
}

variable "aws_auth_node_iam_role_arns_non_windows" {
  type = list(string)
}

variable "add_userdata" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script"
  type        = string
}

variable "worker_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  type        = string
}

// Variables for spot pool
variable "spot_instance_types" {
  description = "AWS instance type to build nodes for spot pool"
  type        = list(any)
  default     = [{ instance_type = "r5.xlarge" }, { instance_type = "r5.2xlarge" }]
}

variable "spot_max_nodes_count" {
  description = "The maximum size of the spot autoscaling group"
  type        = number
  default     = 1
}

variable "spot_desired_nodes_count" {
  description = "The number of spot Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "spot_min_nodes_count" {
  description = "The minimum size of the spot autoscaling group"
  type        = number
  default     = 1
}

// Variables for on-demand pool
variable "demand_instance_types" {
  description = "AWS instance type to build nodes for on-demand pool"
  type        = list(any)
  default     = [{ instance_type = "r5.xlarge" }]
}

variable "demand_max_nodes_count" {
  description = "The maximum size of the on-demand autoscaling group"
  default     = 1
}

variable "demand_desired_nodes_count" {
  description = "The number of on-demand Amazon EC2 instances that should be running in the autoscaling group"
  default     = 1
}

variable "demand_min_nodes_count" {
  description = "The minimum size of the on-demand autoscaling group"
  default     = 1
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}


variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
}

# OIDC
variable "client_id" {
  description = "Client ID for the OpenID Connect identity provider."
  type        = string
}

variable "identity_provider_config_name" {
  description = "The name of the identity provider config."
  type        = string
}

variable "issuer_url" {
  description = "Issuer URL for the OpenID Connect identity provider."
  type        = string
}

variable "groups_claim" {
  description = "The JWT claim that the provider will use to return groups."
  type        = string
}
