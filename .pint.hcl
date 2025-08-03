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
# https://cloudflare.github.io/pint/checks/promql/series.html
check "promql/series" {
  lookbackRange           = "2d"
  ignoreMetrics           = [ "(.*)", ... ]
  ignoreLabelsValue       = { "...": [ "...", ... ] }
}
