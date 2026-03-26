provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority)
    config_path    = ""
    config_context = ""

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.name]
      }
  }
}

module "nginx_ingress_controller" {
  source = "../modules/eks/nginx-ingress-controller"
}
