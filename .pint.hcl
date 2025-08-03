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
  ignoreMetrics = [
    "cilium_clustermesh_remote_cluster_failures",
    "cilium_kvstoremesh_kvstore_sync_errors_total",
    "cilium_kvstoremesh_remote_cluster_failures",
    "cilium_kvstoremesh_remote_cluster_readiness_status",
    "cortex_alertmanager_.*_invalid_total",
    "cortex_alertmanager_.*_failed_total",
    "cortex_alertmanager_partial_state_merges_total",
    "node_md.*",  # We don't use md, that's fine.
    "node_systemd.*",  # Talos doesn't use systemd, that's fine.
    "mimir_.*_failed_total",
    "aggregator_unavailable_apiservice_total", # kubernetes-system-apiserver
    "kubelet_evictions",  # kubernetes-system-kubelet
    "kubelet_server_expiration_renew_errors",
    "kube_horizontalpodautoscaler.*",
   ]
  ignoreLabelsValue       = {
    "cilium_agent_api_process_time_seconds_count" = [ "return_code" ],
    "cilium_datapath_conntrack_gc_runs_total" = ["status"],
    "cilium_drop_count_total" = [ "reason" ],
    "cilium_endpoint_state" = [ "endpoint_state" ],
    "kube_node_spec_taint" = [ "key" ],  # kube-state-metrics
    "kube_persistentvolumeclaim_access_mode" = [ "access_mode" ],
    "cilium_k8s_client_api_calls_total" = ["endpoint" ],
  }
}
