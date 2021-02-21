//The Kubernetes (K8S) provider is used to interact with the resources supported by Kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  //PEM-encoded root certificates bundle for TLS
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  
  //Configuration block to use an exec-based credential plugin, in this case call an external command (aws) to receive user credentials(token).
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}
