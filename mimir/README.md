# tales/mimir

## Status

- Updated for https://grafana.com/docs/helm-charts/mimir-distributed/latest/migration-guides/migrate-to-unified-proxy-deployment/
- Alert Manager serving outside the cluster over https at https://mimir.local.symmatree.com/alertmanager/
- TODO: AlertManager-to-Apprise config
- We have a few alerts for Loki, Mimir, ArgoCD coming from their own Helm.

## Debugging

A bunch of services serve UIs on 8080. Any of

```
k port-forward -n mimir mimir-ingester-0 8080:8080
k port-forward -n mimir mimir-distributor-59787d98c8-7bvpg 8080:8080
```

With current settings (save a few messages) Ingester has a very nice UI
at http://localhost:8081/memberlist (or whatever) so we might be able
to figure out which ring is complaining, if it still is.
