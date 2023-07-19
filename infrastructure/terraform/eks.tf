# module "eks" {
#   source = "terraform-aws-modules/eks/aws"

#   cluster_name    = var.cluster_name
#   cluster_version = "1.26"

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets 

#   eks_managed_node_group_defaults = {
#     disk_size = 50
#   }
#   eks_managed_node_groups = {
#     node_2 = {
#       desired_size = 1
#       min_size     = 1
#       max_size     = 3

#       labels = {
#         role = "production"
#       }

#       instance_types = ["t3.small"]
#       capacity_type  = "ON_DEMAND"
#     }

#     node_3 = {
#       desired_size = 1
#       min_size     = 1
#       max_size     = 3

#       labels = {
#         role = "spot"
#       }

#       instance_types = ["t3.small"]
#       capacity_type  = "ON_DEMAND"
#     }
#   }

# }
