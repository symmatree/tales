parser {
  schema  = "prometheus"
  names   = "utf-8"
  relaxed = [ "(.*)"]
}

prometheus "tales-mimir" {
  uri = "https://mimir.local.symmatree.com/prometheus"
  required = true
}
