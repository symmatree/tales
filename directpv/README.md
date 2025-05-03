# directpv

They really don't like Helm and they only kinda expose kustomize.

```
kubectl krew install directpv
kubectl directpv install -o yaml \
  --tolerations key=value:NoSchedule \
   > manifests.yaml
```

There's actually also a very nice looking helm chart in Github...

Anyway I ran this, customized a little. Re-run to see the diffs.

Newer: I extended the install to include the 1.0T utility drives
on each node, in addition to the 2T that's intended for minio. So
I need to label them.

```
# List the drives, with ids
kubectl directpv list drives -o wide
kubectl directpv label drives use=general \
  --ids a11fb435-fa24-4e77-ad75-6580b62a501b,3760a41b-0201-4305-9c2e-dfd3034a5186
kubectl directpv label drives use=minio \
  --ids d03029e1-9506-48d2-a1e2-141f4c8a54d7
```

