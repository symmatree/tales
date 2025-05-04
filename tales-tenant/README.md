# tales-tenant -- minio storage



## Ingress

It has a TLS backend and tbh that seems good for core storage, but that means cilium ingress can't
front for it because it can only do an http backhaul for some bizarre reason. So either I need to
finally buckle and install an nginx-ingress to support that, or we just expose the services directly.

Current strategy is using the self-signed cluster-wide tales CA as an issuer for both the operator
and the tenant, rather than the many many certs in the [docs](https://min.io/docs/minio/kubernetes/upstream/operations/cert-manager/cert-manager-tenants.html)

Thanks to enabling trust-manager to inject secrets, both minio-tenant and minio-operator
can have the self-signed root CA injected in a way they'll pick up (name-sensitive in both cases);
those are in their respective deployments. So we don't need to do the manual glue
described in the docs. Instead, `tales-tenant-cert` is just a normal cert request,
and just the public key of the CA is injected.

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

# NO LONGER REQUIRED, YAY
# Make minio-operator trust the cert
# kubectl get secret tales-tenant-ca-tls -n tales-tenant \
#   -o jsonpath="{.data.tls\.crt}" \
#   | base64 -d > ca.crt
# kubectl create secret generic operator-ca-tls-tales-tenant --from-file=ca.crt -n minio-operator
# rm ca.crt

mc alias set tales https://minio.local.symmatree.com \
    "$(op read op://tales-secrets/minio-admin/username)" \
    "$(op read op://tales-secrets/minio-admin/password)"

mc admin info tales
```

## Stuck Progressing

Check the logs on the minio operator pod, likely it doesn't trust the
root CA and it can't get the health endpoint as a result.
