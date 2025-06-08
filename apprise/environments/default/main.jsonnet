local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local k_util = import 'github.com/grafana/jsonnet-libs/ksonnet-util/util.libsonnet';
local op = import 'op.libsonnet';

local apprise = {
  local kDeployment = k.apps.v1.deployment,
  local kContainer = k.core.v1.container,
  local kPort = k.core.v1.containerPort,
  local kConfigMap = k.core.v1.configMap,
  local kVolumeMount = k.core.v1.volumeMount,
  local kPersistentVolumeClaim = k.core.v1.persistentVolumeClaim,
  local kEnvFromSource = k.core.v1.envFromSource,

  local defaults = {
    name: 'apprise',
    image: 'caronc/apprise',
    version: '1.2',
    // Ref https://github.com/caronc/apprise-api#environment-variables
    envSecret: 'apprise-env',
    htpasswdSecret: 'apprise-admin',
    port: kPort.new('https', 8000),
    ingressAnnotations: {
      'cert-manager.io/cluster-issuer': 'real-cert',
    },
    ingressClassName: 'cilium',
    host: 'apprise.local.symmatree.com',
  },
  new(overrides):: {
    local appriseObj = self,
    local config = defaults + overrides,
    envSecret: op.item.new(config.envSecret, 'vaults/tales-secrets/items/' + config.envSecret),
    htpasswd: op.item.new(config.htpasswdSecret, 'vaults/tales-secrets/items/' + config.htpasswdSecret),
    configPvc: kPersistentVolumeClaim.new(std.format('%s-config', config.name))
               + kPersistentVolumeClaim.spec.withAccessModes(['ReadWriteOnce'])
               + kPersistentVolumeClaim.spec.resources.withRequestsMixin({ storage: '1Gi' }),
    attachPvc: kPersistentVolumeClaim.new(std.format('%s-attach', config.name))
               + kPersistentVolumeClaim.spec.withAccessModes(['ReadWriteOnce'])
               + kPersistentVolumeClaim.spec.resources.withRequestsMixin({ storage: '10Gi' }),
    nginxConfig: kConfigMap.new(std.format('%s-nginx', config.name))
                 + kConfigMap.withData({
                   'location-override.conf': |||
                     satisfy any;
                     # Allow access from cluster without login.
                     allow 127.0.0.0/8;
                     allow 10.0.4.0/23;  # pod
                     allow 10.0.8.0/24;  # external
                     allow 10.0.6.0/23;  # service
                     deny all;
                     auth_basic            "Apprise API Restricted Area";
                     auth_basic_user_file  /etc/nginx/.htpasswd;
                   |||,
                 }),
    deployment:
      kDeployment.new(config.name, replicas=1, containers=[
        local healthProbe(probe) =
          probe.withInitialDelaySeconds(10)
          + probe.withPeriodSeconds(10)
          + probe.httpGet.withPath('/status')
          // + probe.httpGet.withPort(config.port.port)
          + probe.httpGet.withScheme('HTTP')
          + probe.withSuccessThreshold(1);
        local livenessProbe = kContainer.livenessProbe;
        local readinessProbe = kContainer.readinessProbe;
        kContainer.new(config.name, std.format('%s:%s', [config.image, config.version]))
        + kContainer.withPorts([config.port])
        + kContainer.withEnvMap({
          IPV4_ONLY: 'yes',
          APPRISE_STATELESS_STORAGE: 'yes',
          APPRISE_ATTACH_SIZE: '500',
          APPRISE_STATEFUL_MODE: 'simple',
          APPRISE_ADMIN: 'yes',
          APPRISE_RECURSION_MAX: '5',
          APPRISE_WORKER_COUNT: '1',
        })
        + kContainer.withEnvFromMixin(
          kEnvFromSource.secretRef.withName(appriseObj.envSecret.metadata.name)
        )
        + healthProbe(livenessProbe)
        + livenessProbe.withFailureThreshold(6)
        + healthProbe(readinessProbe)
        + readinessProbe.withFailureThreshold(3),
      ])
      + kDeployment.spec.template.spec.withTerminationGracePeriodSeconds(30)
      + k_util.pvcVolumeMount(appriseObj.configPvc.metadata.name, '/config')
      + k_util.pvcVolumeMount(appriseObj.attachPvc.metadata.name, '/attach')
      + k_util.configMapVolumeMount(
        appriseObj.nginxConfig,
        '/etc/nginx/.htpasswd',
        kVolumeMount.withSubPath('.htpasswd') + kVolumeMount.withReadOnly(true)
      ),
    service: k_util.serviceFor(self.deployment, nameFormat='%(container)s'),
    local kIngress = k.networking.v1.ingress,
    local kIngressRule = k.networking.v1.ingressRule,
    local kHttpIngressPath = k.networking.v1.httpIngressPath,
    local kIngressTLS = k.networking.v1.ingressTLS,
    ingress:
      kIngress.new(std.format('%s-ingress', config.name))
      + kIngress.metadata.withAnnotations(config.ingressAnnotations)
      + kIngress.spec.withIngressClassName(config.ingressClassName)
      + kIngress.spec.withRulesMixin([
        kIngressRule.withHost(config.host)
        + kIngressRule.http.withPathsMixin(
          kHttpIngressPath.withPath('/')
          + kHttpIngressPath.withPathType('Prefix')
          + kHttpIngressPath.backend.service.withName(self.service.metadata.name)
          + kHttpIngressPath.backend.service.port.withName(config.port.name)
        ),
      ])
      + kIngress.spec.withTlsMixin([
        kIngressTLS.withHosts([config.host])
        + kIngressTLS.withSecretName(std.format('%s-tls', config.name)),
      ]),
  },
};

apprise.new({})
