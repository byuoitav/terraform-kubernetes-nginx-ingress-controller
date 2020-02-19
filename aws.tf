// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/provider/aws/service-nlb.yaml
resource "kubernetes_service" "lb" {
  metadata {
    name      = local.nginx
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = local.nginx
      "app.kubernetes.io/part-of"    = local.nginx
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    type = "LoadBalancer"
    selector = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }

    external_traffic_policy = "Local"

    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = "http"
    }

    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = "https"
    }
  }
}
