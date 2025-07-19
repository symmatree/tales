local k = import 'github.com/jsonnet-libs/k8s-libsonnet/1.32/main.libsonnet';
local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.77/main.libsonnet';

{
  local kConfigMap = k.core.v1.configMap,
  local kPrometheusRule = po.monitoring.v1.prometheusRule,

  local defaults = {
    folder: 'Misc',
    namespace: error 'namespace',
    dashboardsToDrop: [],  // Dashboards to remove
    alertsToDrop: [],  // Groups to remove
    rulesToDrop: [],  // Groups to remove
    dirAnnotation: 'k8s-sidecar-target-directory',  // This aligns with grafana/values.yaml
  },
  new(mixin, overrides)::
    {
      fields:: std.trace(
        'mixin fields: ' + std.join(', ', std.objectFields(mixin)),
      ),

      local toK8s(name) =
        std.strReplace(std.strReplace(std.strReplace(std.asciiLower(name), ' ', '-'), '_', '-'), '.json', ''),
      mixin:: mixin,
      local config = defaults + overrides,
      local dashBlobs = mixin.grafanaDashboards,
      dashboards: std.filterMap(
        function(name)
          !std.member(config.dashboardsToDrop, toK8s(name)),
        function(name)
          // Each configMap contains one dashboard to avoid the size limit of a configMap.
          kConfigMap.new(toK8s(name))
          + kConfigMap.metadata.withNamespace(config.namespace)
          + kConfigMap.metadata.withLabelsMixin({ grafana_dashboard: '1' })
          + kConfigMap.metadata.withAnnotationsMixin({ [config.dirAnnotation]: '/tmp/dashboards/' + config.folder })
          + kConfigMap.withData({ [name]: std.manifestJson(dashBlobs[name]) }),
        std.objectFields(dashBlobs)
      ),

      // Each group in a separate object to limit max size.
      alerts: std.filterMap(
        function(group)
          !std.member(config.rulesToDrop, toK8s(group.name)),
        function(group)
          kPrometheusRule.new(toK8s(group.name))
          + kPrometheusRule.metadata.withNamespace(config.namespace)
          + kPrometheusRule.spec.withGroups([group]),
        mixin.prometheusAlerts.groups
      ),

      // Each group in a separate object to limit max size.
      rules: std.filterMap(
        function(group)
          !std.member(config.rulesToDrop, toK8s(group.name)),
        function(group)
          kPrometheusRule.new(toK8s(group.name))
          + kPrometheusRule.metadata.withNamespace(config.namespace)
          + kPrometheusRule.spec.withGroups([group]),
        std.get(mixin, 'prometheusRules', { groups: [] }).groups
      ),
    },
}
