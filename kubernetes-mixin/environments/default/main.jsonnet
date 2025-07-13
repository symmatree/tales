local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.29/main.libsonnet';
local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.77/main.libsonnet';
local libMixin = import 'github.com/kubernetes-monitoring/kubernetes-mixin/mixin.libsonnet';

local rendered = {
  local kConfigMap = k.core.v1.configMap,
  local kPrometheusRule = po.monitoring.v1.prometheusRule,

  local defaults = {
    folder: 'Kubernetes',
    namespace: 'kubernetes-mixin',
  },
  new(overrides):: {
    local config = defaults + overrides,
    local mixin = libMixin {
      _config+:: {
        // Correct defaults:
        // kubeControllerManagerSelector: 'job="kube-controller-manager"',
        // kubeSchedulerSelector: 'job="kube-scheduler"',
        // Doesnt exist:
        // kubeProxySelector: 'job="kube-proxy"',

        kubeApiserverSelector: 'job="integrations/kubernetes/kube-apiserver"',
        kubeStateMetricsSelector: 'job="integrations/kubernetes/kube-state-metrics"',
        cadvisorSelector: 'job="integrations/kubernetes/cadvisor"',
        kubeletSelector: 'job="integrations/kubernetes/kubelet"',
        nodeExporterSelector: 'job="integrations/node_exporter"',

        grafanaK8s+:: {
          grafanaTimezone: 'browser',
        },
        showMultiCluster: true,
      },
      local dashBlobs = mixin.grafanaDashboards,
      dashboards: std.map(
        function(name)
          local k8sName = std.strReplace(std.asciiLower(name), ' ', '-');
          kConfigMap.new(k8sName)
          + kConfigMap.metadata.withNamespace(config.namespace)
          + kConfigMap.metadata.withLabelsMixin({ grafana_dashboard: '1' })
          + kConfigMap.metadata.withAnnotationsMixin({ 'k8s-sidecar-target-directory': '/tmp/dashboards/' + config.folder })
          + kConfigMap.withData({ [name]: std.manifestJson(dashBlobs[name]) }),
        std.objectFields(dashBlobs)
      ),

      local alertGroups = mixin.prometheusAlerts.groups,
      alerts: std.map(
        function(group)
          local name = std.strReplace(std.asciiLower(group.name), ' ', '-');
          kPrometheusRule.new(name)
          + kPrometheusRule.metadata.withNamespace(config.namespace)
          + kPrometheusRule.spec.withGroups([group]), alertGroups
      ),
    },
  },
};

rendered.new({})
