
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "SelaClaster"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo hello from k8s"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]
}

//Retrieve information about an EKS Cluster.
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

//Get an authentication token to communicate with an EKS cluster.
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
