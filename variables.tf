variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.23"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "private_subnets_id" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
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
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "spot_desired_nodes_count" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "spot_min_nodes_count" {
  description = "The minimum size of the autoscaling group"
  type        = number
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