// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/mandatory.yaml
locals {
  nginx = "ingress-nginx"
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = local.nginx

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-configuration"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }
}

resource "kubernetes_config_map" "nginx_tcp" {
  metadata {
    name      = "tcp-services"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }
}

resource "kubernetes_config_map" "nginx_udp" {
  metadata {
    name      = "udp-services"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }
}

resource "kubernetes_cluster_role" "nginx" {
  metadata {
    name = "nginx-ingress-clusterrole"

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}

resource "kubernetes_role" "nginx" {
  metadata {
    name      = "nginx-ingress-role"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "nginx" {
  metadata {
    name      = "nginx-ingress-role-nisa-binding"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.nginx.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx.metadata.0.name
    namespace = kubernetes_service_account.nginx.metadata.0.namespace
  }
}

resource "kubernetes_cluster_role_binding" "nginx" {
  metadata {
    name = "nginx-ingress-clusterrole-nisa-binding"

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx.metadata.0.name
    namespace = kubernetes_service_account.nginx.metadata.0.namespace
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"    = local.nginx
        "app.kubernetes.io/part-of" = local.nginx
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = local.nginx
          "app.kubernetes.io/part-of" = local.nginx
        }

        annotations = {
          "prometheus.io/port" : "10254"
          "prometheus.io/scrape" : "true"
        }
      }

      spec {
        // wait up to 5 minutes to drain connections
        termination_grace_period_seconds = 300
        service_account_name             = kubernetes_service_account.nginx.metadata.0.name

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.29.0"

          args = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/nginx-configuration",
            "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
            "--udp-services-configmap=$(POD_NAMESPACE)/udp-services",
            "--publish-service=$(POD_NAMESPACE)/ingress-nginx",
            "--annotations-prefix=nginx.ingress.kubernetes.io"
          ]

          security_context {
            allow_privilege_escalation = true
            run_as_user                = 101
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            protocol       = "TCP"
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 10
            success_threshold     = 1
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            period_seconds    = 10
            timeout_seconds   = 10
            success_threshold = 1
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_limit_range" "nginx" {
  metadata {
    name = local.nginx

    labels = {
      "app.kubernetes.io/name"    = local.nginx
      "app.kubernetes.io/part-of" = local.nginx
    }
  }

  spec {
    limit {
      type = "Container"
      min = {
        "memory" = "90Mi"
        "cpu"    = "100m"
      }
    }
  }
}
