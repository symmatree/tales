parser {
  schema  = "prometheus"
  names   = "utf-8"
  relaxed = [ "(.*)"]
}

checks {
  disabled = [
    "promql/regexp",  # Triggers on default values that happen to be literal strings
    ]
}
prometheus "tales-mimir" {
  uri = "https://mimir.local.symmatree.com/prometheus"
  required = true
}
