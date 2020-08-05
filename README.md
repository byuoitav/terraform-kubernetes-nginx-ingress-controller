# terraform-kubernetes-nginx-ingress-controller

### Sample usage

```
module nginx-ingress-controller {
  source  = "byuoitav/nginx-ingress-controller/kubernetes"
  version = "0.1.12",

  # optional
  nginx_config {
    "ssl-protocols"     = "TLSv1.2" # Only Support TLSv1.2
	"proxy-buffer-size" = "16k"
  }
}
```
