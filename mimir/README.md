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

## Config

Mimir config is...interesting. It can be provisioned through the filesystem or mimirtool
or via Grafana.

Current config is:

```
global:
  resolve_timeout: 5m
  http_config:
    follow_redirects: true
    enable_http2: true
  smtp_hello: localhost
  smtp_require_tls: true
  pagerduty_url: https://events.pagerduty.com/v2/enqueue
  opsgenie_api_url: https://api.opsgenie.com/
  wechat_api_url: https://qyapi.weixin.qq.com/cgi-bin/
  victorops_api_url: https://alert.victorops.com/integrations/generic/20131114/alert/
  telegram_api_url: https://api.telegram.org
  webex_api_url: https://webexapis.com/v1/messages
route:
  receiver: tales
  group_by:
  - namespace
  continue: false
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
receivers:
- name: default-receiver
- name: bond
  webhook_configs:
  - send_resolved: true
    http_config:
      follow_redirects: true
      enable_http2: true
    url: <secret>
    url_file: ""
    max_alerts: 0
    timeout: 0s
- name: tales
  webhook_configs:
  - send_resolved: true
    http_config:
      follow_redirects: true
      enable_http2: true
    url: <secret>
    url_file: ""
    max_alerts: 0
    timeout: 0s
- name: priority
  webhook_configs:
  - send_resolved: true
    http_config:
      follow_redirects: true
      enable_http2: true
    url: <secret>
    url_file: ""
    max_alerts: 0
    timeout: 0s
templates: []
```
