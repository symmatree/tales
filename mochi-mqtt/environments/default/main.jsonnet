local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local k_util = import 'github.com/grafana/jsonnet-libs/ksonnet-util/util.libsonnet';

local mochi = {
  local kDeployment = k.apps.v1.deployment,
  local kContainer = k.core.v1.container,
  local kPort = k.core.v1.containerPort,
  local kService = k.core.v1.service,
  local kConfigMap = k.core.v1.configMap,
  local kVolumeMount = k.core.v1.volumeMount,
  local kVolume = k.core.v1.volume,
  local kPersistentVolumeClaim = k.core.v1.persistentVolumeClaim,

  local defaults = {
    name: 'mochi-mqtt',
    image: 'mochimqtt/server',
    version: '2.7',
    pvcName: 'mochi-pebble',
  },
  new(overrides):: {
    local mochiObj = self,
    local config = defaults + overrides,
    pvc: kPersistentVolumeClaim.new('mochi-pebble')
         + kPersistentVolumeClaim.spec.withAccessModes(['ReadWriteOnce'])
         + kPersistentVolumeClaim.spec.resources.withRequestsMixin({ storage: '10Gi' }),
    serverConfig:
      kConfigMap.new('mochi-config')
      + kConfigMap.withData({
        // It ignores filename and sniffs first byte for { to detect json.
        'config.yaml': std.manifestYamlDoc({
          listeners: [
            { type: 'healthcheck', id: 'http-health', address: ':8080' },
            { type: 'sysinfo', id: 'http-sysinfo', address: ':8081' },
            { type: 'ws', id: 'websocket', address: ':1882' },
            { type: 'tcp', id: 'mqtt', address: ':1883' },
          ],
          hooks: {
            storage: {
              pebble: {
                path: '/mnt/mochi-pebble/pebble.db',
                mode: 'Sync',
              },
            },
            auth: {
              allow_all: true,
            },
          },
          // https://github.com/mochi-mqtt/server/blob/main/server.go
          options: {},
          logging: {},
        }),
      }),
    deployment:
      kDeployment.new(config.name, replicas=1, containers=[
        local healthProbe(probe) =
          probe.withInitialDelaySeconds(10)
          + probe.withPeriodSeconds(10)
          + probe.httpGet.withPath('/healthcheck')
          + probe.httpGet.withPort(8080)
          + probe.httpGet.withScheme('HTTP')
          + probe.withSuccessThreshold(1);
        local livenessProbe = kContainer.livenessProbe;
        local readinessProbe = kContainer.readinessProbe;
        kContainer.new(config.name, config.image + ':' + config.version)
        + kContainer.withPorts([
          kPort.new('http-health', 8080),  // /healthcheck
          kPort.new('http-sysinfo', 8081),  // /
          kPort.new('websocket', 1882),
          kPort.new('mqtt', 1883),
        ])
        + healthProbe(livenessProbe)
        + livenessProbe.withFailureThreshold(6)
        + healthProbe(readinessProbe)
        + readinessProbe.withFailureThreshold(3),
      ])
      + kDeployment.spec.template.spec.withTerminationGracePeriodSeconds(30)
      + k_util.pvcVolumeMount(mochiObj.pvc.metadata.name, '/mnt/mochi-pebble')
      + k_util.configMapVolumeMount(mochiObj.serverConfig, '/config.yaml', kVolumeMount.withSubPath('config.yaml') + kVolumeMount.withReadOnly(true)),
    service: k_util.serviceFor(self.deployment, nameFormat='%(port)s'),
  },
};

mochi.new({})
