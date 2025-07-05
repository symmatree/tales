#! jsonnet --string
local config = {
  helmDirs: [
    '/alloy',
    '/argocd',
    '/cert-manager',
    '/cilium',
    '/connect',
    '/external-dns',
    '/kubernetes-dashboard',
    '/minio-operator',
    '/static-certs',
    '/tales-tenant',
    '/grafana',
    '/jupyterhub',
    '/loki',
    '/mimir',
  ],
};

std.manifestYamlDoc(quote_keys=false, value={
  version: 2,
  updates: [
    {
      'package-ecosystem': 'helm',
      directory: d,
      schedule: {
        interval: 'weekly',
      },
    }
    for d in config.helmDirs
  ] + [
    {
      'package-ecosystem': 'github-actions',
      directory: '/',
      schedule: {
        interval: 'weekly',
      },
    },
  ],
})
