# directpv

They really don't like Helm and they only kinda expose kustomize.

```
kubectl krew install directpv
kubectl directpv install -o yaml \
  --tolerations key=value:NoSchedule \
   > manifests.yaml
```

There's actually also a very nice looking helm chart in Github
