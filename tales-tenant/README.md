# tales-tenant -- minio storage



## Ingress

It has a TLS backend and tbh that seems good for core storage, but that means cilium ingress can't
front for it because it can only do an http backhaul for some bizarre reason. So either I need to
finally buckle and install an nginx-ingress to support that, or we just expose the services directly.

Current state is to expose services directly instead, with a TLS that we don't recognize until we install it directly, below.

The same `.crt` file can be installed on Windows using the `Certificates`
`mmc.exe` snap-in to install to trusted roots for both the user and
the local computer.

## mc command line setup

Just download the binary whatever.

```
# These hostnames appear in templates/tenant-ca.yaml
# and in values.yaml.
kubens tales-tenant
k annotate svc/minio \
  "external-dns.alpha.kubernetes.io/hostname=minio.local.symmatree.com"
k annotate svc/tales-tenant-console \
  "external-dns.alpha.kubernetes.io/hostname=minio-console.local.symmatree.com"

kubectl get secret tales-tenant-ca-tls -n tales-tenant \
  -o jsonpath="{.data.tls\.crt}" \
  | base64 -d \
  | sudo tee /usr/local/share/ca-certificates/tales-tenant-ca-tls.crt
sudo update-ca-certificates

mc alias set tales https://minio.local.symmatree.com \
    "$(op read op://tales-secrets/minio-admin/username)" \
    "$(op read op://tales-secrets/minio-admin/password)"
```
