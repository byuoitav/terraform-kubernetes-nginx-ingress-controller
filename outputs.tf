output "lb_hostname" {
  value       = kubernetes_service.lb.hostname
  description = "The hostname of the LB created by kubernetes"
}
