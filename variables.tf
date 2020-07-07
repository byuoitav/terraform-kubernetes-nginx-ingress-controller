variable "nginx_ingress_controller_version" {
  description = "The version of Nginx Ingress Controller to use. See https://github.com/kubernetes/ingress-nginx/releases for available versions"
  type        = string
  default     = "0.29.0"
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

variable "controller_replicas" {
  description = "Desired number of replicas of the nginx ingress controller pod"
  type        = number
  default     = 1
}
