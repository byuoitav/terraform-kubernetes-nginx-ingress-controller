// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/provider/aws/service-nlb.yaml
resource "kubernetes_service" "lb" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = var.lb_annotations
  }

  spec {
    type = "LoadBalancer"
    selector = {
      "app.kubernetes.io/name"    = var.name
      "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
    }

    external_traffic_policy = "Local"

    dynamic "port" {
      for_each = var.lb_ports

      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }
    load_balancer_source_ranges = var.load_balancer_source_ranges
  }
}
