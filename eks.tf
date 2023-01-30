data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

locals {
  cluster_name              = "my-cluster"
  cluster_version           = var.cluster_version
  cluster_security_group_id = data.aws_security_group.default.id

  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users
  tags = {
    "SysName"      = "EPAM"
    "SysOwner"     = "SpecialEPMD-EDPcoreteam@epam.com"
    "Environment"  = "EKS-SANDBOX-CLUSTER"
    "CostCenter"   = "2023"
    "BusinessUnit" = "EDP"
    "Department"   = "EPMD-EDP"
    "user:tag"     = local.cluster_name
  }
  create_eks = false
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  create = local.create_eks ? 1 : 0

  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  #  cluster_addons = {
  #    coredns = {
  #      most_recent = true
  #    }
  #    kube-proxy = {
  #      most_recent = true
  #    }
  #    vpc-cni = {
  #      most_recent = true
  #    }
  #  }

  vpc_id     = var.vpc_id
  subnet_ids = [var.private_subnets_id[1]] #var.private_subnets_id

  create_cloudwatch_log_group                = false
  cluster_enabled_log_types                  = []
  create_node_security_group                 = false
  create_cluster_primary_security_group_tags = false

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_security_group_id

  cluster_encryption_config = {}

  aws_auth_node_iam_role_arns_non_windows = var.aws_auth_node_iam_role_arns_non_windows

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type              = "r5.large"
    post_bootstrap_user_data   = var.add_userdata
    target_group_arns          = [] #module.alb.target_group_arns
    key_name                   = module.key_pair.key_pair_name
    enable_monitoring          = false
    use_mixed_instances_policy = true
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 30
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = false
          delete_on_termination = true
        }
      }
    }

    # IAM role
    create_iam_instance_profile = false
    iam_instance_profile_arn    = var.worker_iam_instance_profile_arn
  }

  self_managed_node_groups = {
    worker_group_spot = {
      name = format("%s-%s", local.cluster_name, "spot")

      min_size     = var.spot_min_nodes_count
      max_size     = var.spot_max_nodes_count
      desired_size = var.spot_desired_nodes_count

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      mixed_instances_policy = {
        instances_distribution = {
          spot_instance_pools = 0
        }
        override = var.spot_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.spot_min_nodes_count
          max_size     = var.spot_max_nodes_count
          desired_size = var.spot_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
    worker_group_on_demand = {
      name = format("%s-%s", local.cluster_name, "on-demand")

      min_size     = var.demand_min_nodes_count
      max_size     = var.demand_max_nodes_count
      desired_size = var.demand_desired_nodes_count

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'"

      mixed_instances_policy = {
        override = var.demand_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.demand_min_nodes_count
          max_size     = var.demand_max_nodes_count
          desired_size = var.demand_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
  }

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles            = local.aws_auth_roles
  aws_auth_users            = local.aws_auth_users

  tags = var.tags
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  create = local.create_eks ? 1 : 0

  key_name_prefix    = local.cluster_name
  create_private_key = true

  tags = local.tags
}