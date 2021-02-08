variable "name" {
  description = "The name of this nginx ingress controller"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_ingress_controller_version" {
  description = "The version of Nginx Ingress Controller to use. See https://github.com/kubernetes/ingress-nginx/releases for available versions"
  type        = string
  default     = "0.44.0"
}

variable "nginx_config" {
  description = "Data in the k8s config map. See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap for options"
  default     = {}
}

variable "lb_annotations" {
  description = "Annotations to add to the loadbalancer"
  type        = map(string)
  default = {
    "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  }
}

variable "load_balancer_source_ranges" {
  description = "The ip whitelist that is allowed to access the load balancer"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "lb_ports" {
  description = "Load balancer port configuration"
  type = list(object({
    name        = string
    port        = number
    target_port = string
  }))
  default = [{
    name        = "http"
    port        = 80
    target_port = "http"
    }, {
    name        = "https"
    port        = 443
    target_port = "https"
  }]
}

variable "priority_class_name" {
  description = "The priority class to attach to the deployment"
  type        = string
  default     = null
}

variable "controller_replicas" {
  description = "Desired number of replicas of the nginx ingress controller pod"
  type        = number
  default     = 1
}

variable "disruption_budget_max_unavailable" {
  description = "The maximum unavailability of the nginx deployment"
  type = string
  default = "50%"
}
