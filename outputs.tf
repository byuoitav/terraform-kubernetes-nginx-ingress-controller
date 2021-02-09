output "lb_address" {
  value       = length(kubernetes_service.lb.status[0].load_balancer[0].ingress[0].ip) > 0 ? kubernetes_service.lb.status[0].load_balancer[0].ingress[0].ip : kubernetes_service.lb.status[0].load_balancer[0].ingress[0].hostname
  description = "The hostname of the LB created by kubernetes"
}

output "ingress_class" {
  value = var.name
}
