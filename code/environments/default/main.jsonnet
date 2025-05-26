local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local k_util = import 'github.com/grafana/jsonnet-libs/ksonnet-util/util.libsonnet';

local code = {
  local kDeployment = k.apps.v1.deployment,
  local kContainer = k.core.v1.container,
  local kPort = k.core.v1.containerPort,
  local kService = k.core.v1.service,
  local kConfigMap = k.core.v1.configMap,
  local kVolumeMount = k.core.v1.volumeMount,
  local kVolume = k.core.v1.volume,
  local kPersistentVolumeClaim = k.core.v1.persistentVolumeClaim,

  local defaults = {
    name: 'code',
    image: 'ubuntu',
    version: '24.04',
    pvcName: 'home',
    username: 'symmetry',
  },
  new(overrides):: {
    local codeObj = self,
    local config = defaults + overrides,
    pvc: kPersistentVolumeClaim.new(config.pvcName)
         + kPersistentVolumeClaim.spec.withAccessModes(['ReadWriteOnce'])
         + kPersistentVolumeClaim.spec.resources.withRequestsMixin({ storage: '10Gi' }),
    sshdConfig:
      kConfigMap.new('sshd-config')
      + kConfigMap.withData({
        sshd_config: std.manifestIni({
          main: {
            PermitRootLogin: 'no',
            PasswordAuthentication: 'no',
            KbdInteractiveAuthentication: 'no',
            UsePAM: 'no',
            X11Forwarding: 'yes',
            PrintMotd: 'no',
            PermitUserEnvironment: 'yes',
            PermitTunnel: 'yes',
            AcceptEnv: 'LANG LC_*',
          },
        }),
      }),
    deployment:
      kDeployment.new(config.name, replicas=1, containers=[
        kContainer.new(config.name, config.image + ':' + config.version)
        + kContainer.withPorts([
          kPort.new('ssh', 22),
        ]),
      ])
      + kDeployment.spec.template.spec.withTerminationGracePeriodSeconds(30)
      + k_util.pvcVolumeMount(codeObj.pvc.metadata.name, '/home/' + config.userName)
      + k_util.configMapVolumeMount(codeObj.sshdConfig, '/etc/ssh/sshd_config', kVolumeMount.withSubPath('sshd_config') + kVolumeMount.withReadOnly(true)),
    service: k_util.serviceFor(self.deployment, nameFormat='%(port)s'),
  },
};

code.new({})
