# terraform-kubernetes-nginx-ingress-controller

### Sample usage

```
module nginx-ingress-controller {
  source  = "byuoitav/nginx-ingress-controller/kubernetes"
  version = "0.2.0",

  # optional
  name = "ingress-nginx"
  nginx_config {
    "ssl-protocols"     = "TLSv1.2" # Only Support TLSv1.2
	"proxy-buffer-size" = "16k"
  }
  load_balancer_source_ranges = ["1.2.3.4/32"]
}
```
