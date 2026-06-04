data "aws_eks_cluster" "dev" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "dev" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.dev.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.dev.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.dev.token
  }
}