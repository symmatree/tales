# tales/mimir

## Debugging

A bunch of services serve UIs on 8080. Any of

```
k port-forward -n mimir mimir-ingester-0 8080:8080
k port-forward -n mimir mimir-distributor-59787d98c8-7bvpg 8080:8080
```

With current settings (save a few messages) Ingester has a very nice UI
at http://localhost:8081/memberlist (or whatever) so we might be able
to figure out which ring is complaining, if it still is.
