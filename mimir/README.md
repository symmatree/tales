# tales/mimir

## Status

- Multitenancy disabled (which in some UIs means we are the tenant `anonymous`). Could be
  turned on if useful, this was just to reduce resource usage and complexity.
- Using `mimir-distributed` but most replica counts set to 1 except for `ingester` which requires
  at least 2.
- Accepting metrics and writing to minio. TODO: upstream flow from there for archival storage / recovery.
- Running AlertManager rules and alerts.
- AlertManager-to-Apprise configured, with intermediate sidecar webhook
  to render AlertManager semantic JSON into Apprise rendered-text before
  forwarding to AppRise API for delivery.
- Mimir itself data collection: built-in FooMonitor resources
- Dashboards: built-in dashboards. TODO: Look for a jsonnet mixin?

Note that config and metrics are fully injected by Alloy (in `/alloy`), Mimir itself doesn't
scrape, nor does it interpret the Prometheus Operator CRDs like `PrometheusRule`, but those
are fed to it.

### Serving and using

- Internal entrypoint is `service/mimir-nginx` on port 80, serving HTTP. Within the cluster
  there is neither auth nor protected transport. TODO: Mutual TLS using our self-signed cert manager.
- This service is fronted by an Ingress making it visible outside the cluster. (Note
  that the root url is not user-friendly, at most it says 200 OK.)
- Alert Manager UI visible outside the cluster (w/ https): https://mimir.local.symmatree.com/alertmanager/
- Both AlertManager and Mimir (as metrics) are automatically provisioned as Data Sources in Grafana
- Grafana alerting is disabled and routed to this AlertManager, I think I did that manually.

At one point I had great trouble getting it to restart, which I thought was related to overlapping
lifetimes of old and new instances (because of how ArgoCD deployed) fighting over membership in
the ring it uses for elections. I now suspect much of that was because of a static problem (ingester
requires two instances, period) and error messages that I followed in the wrong direction - but maybe
not. Anyway there are comments and some config relating to trying to get clear "kill-then-create"
lifetimes.

### webhook

Uses docker image built in `webhook/` subdir, which does AlertManager-focused templating.
No great strategy for building or updating it, but we should do so from time to time. The
alertmanager config points to `localhost:3000` which is this.

## Debugging

A bunch of services serve UIs on 8080. Any of

```
k port-forward -n mimir mimir-ingester-0 8080:8080
k port-forward -n mimir mimir-distributor-59787d98c8-7bvpg 8080:8080
```

With current settings (save a few messages) Ingester has a very nice UI
at http://localhost:8081/memberlist (or whatever) so we might be able
to figure out which ring is complaining, if it still is.

## AlertManager Config

Mimir config is...interesting. It can be provisioned through the filesystem or mimirtool
or via Grafana. We end up using either the global "fallback" config or the "anonymous" one since
I disabled multi-tenancy? It is unclear. If you configure through Grafana it seems to get
stored somewhere not the fallback, but needs more testing (or just to turn on multitenancy).

Config is not CURRENTLY auto-provisioned in any way. I think I configured it interactively in
Grafana? At any rate it is saved here, with this command:

```
mimirtool alertmanager get \
  --address=https://mimir.local.symmatree.com \
  --id=anonymous > ./alert-manager-config.yaml
```

## Testing Alerts and Rules

This is actually testing the upstream alert definitions / configs (e.g. kubernetes-mixin),
but the mechanics of testing are at the mimir level.

By hand at present:

One-time setup:

```
cd /usr/local/bin
sudo ~/tales/ci-tools/eget.sh
sudo eget https://github.com/cloudflare/pint --asset=pint-linux-amd64
sudo mv pint-linux-amd64 pint
```

```
export OUT_DIR=/tmp/rules
mkdir -p "$OUT_DIR"
mimirtool rules print \
  --address=https://mimir.local.symmatree.com --id=anonymous \
  --output-dir="$OUT_DIR"
```

then (from the root directory of the repo because that's where `.pint.hcl` lives),

```
export TARGET=kubernetes-mixin
pint lint -n info \
  "${OUT_DIR}/alloy_${TARGET}*"
```
