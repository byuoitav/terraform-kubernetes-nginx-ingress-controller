variable "nginx_ingress_controller_version" {
  description       = "The version of Nginx Ingress Controller to use. See https://github.com/kubernetes/ingress-nginx/releases for available versions"
  type              = string
  default           = "0.29.0"
}

variable "nginx_config" {
  default           = {
    "ssl-protocols" = "TLSv1 TLSv1.1 TLSv1.2"
    "ssl-ciphers"   = "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
  }
}

variable "lb_annotations" {
  default           = {
    "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
  }
}

variable "lb_ports" {
  default           = [{
    name            = "http"
    port            = 80
    target_port     = "http"
  }, {
    name            = "https"
    port            = 443
    target_port     = "https"
  }]
}

variable "controller_replicas" {
  default           = 1
}
