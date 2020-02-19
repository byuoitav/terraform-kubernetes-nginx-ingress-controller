output "lb_hostname" {
  value       = kubernetes_service.lb.load_balancer_ingress
  description = "The hostname of the LB created by kubernetes"
}
