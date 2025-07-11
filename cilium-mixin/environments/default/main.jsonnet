local ciliumMixin = import 'github.com/grafana/jsonnet-libs/cilium-enterprise-mixin/mixin.libsonnet';
local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.29/main.libsonnet';
local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.77/main.libsonnet';

local mixin = {
  local kConfigMap = k.core.v1.configMap,
  local kPrometheusRule = po.monitoring.v1.prometheusRule,

  local defaults = {
    folder: 'Cilium',
    namespace: 'cilium',
  },
  new(overrides):: {
    local config = defaults + overrides,

    local dashBlobs = ciliumMixin.grafanaDashboards,
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

    local alertGroups = ciliumMixin.prometheusAlerts.groups,
    alerts: std.map(
      function(group)
        local name = std.strReplace(std.asciiLower(group.name), ' ', '-');
        kPrometheusRule.new(name)
        + kPrometheusRule.metadata.withNamespace(config.namespace)
        + kPrometheusRule.spec.withGroups([group]), alertGroups
    ),
  },
};

mixin.new({})
