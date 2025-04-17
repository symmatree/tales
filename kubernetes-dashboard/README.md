# tales/dashboard

[Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

## Current status

Working after dropping back to a single hostname. Almost anything seems to confuse or
anger something in the stack, with a single universal symptom of a login screen that
refuses to accept a Bearer Token with an "http parse error". If anyone has a cert
in place, it will usually work to go to the IP address and accept the "invalid" cert,
but not with the actual hostname in the URL.

HOWEVER. If you attach an external IP to the service (cilium LB IPAM), have Cilium advertise it as
an L2 LoadBalancer, give it a *single* hostname, and specify a single hostname as both commonName
and dnsDomains in the cert request, then it seems to work. Multiple hostnames in the cert only
seem to work for one of the two, maybe it's checking against commonName. Anyway I can live with
`dashboard.local.symmatree.com` being the only one that resolves.

Oh, also I set a flag on Helm to disable installing the CRDs since we don't need them and there
are a TON of Kong CRDs.

TODO: Capture argocd applications as resources instead of just in the UI

## Background and notes

This chart is a ROYAL pain! It's a relatively small setup (api, auth and web services), but it insists on
being behind a "kong" gateway (which is doing exactly what an Ingress ought to do but oh well). If you
install it stock, you can port-forward as `kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard-kong-proxy  8080:kong-proxy-tls`
and then access at `https://localhost:8080` but the "native" ingress support in the chart assumes
nginx, and doesn't play nicely with Cilium as far as I can manage.

Configuring their ingest with the knobs in `values.yaml`, I tried to set up Cilium TLS passthrough
but it did not seem to work. Terminating TLS at Cilium didn't work because the backhaul is HTTPS
and Kong insists on that (no http port on the kong proxy service).

I tried disabling Kong in the kubernetes-dashboard chart, and configuring my own ingress in
front of the `web`, `auth` and `api` services. This seems to hit the "not https" failure case
(which is just a cryptic error message when you try to paste in an auth token), but that seems
to indicate that something dropped down to http (possibly dropping the Authentication header
at the same time?)

Most successful has been to just port-forward the kong service. My real complaints with it
are a) when I turned on cert-manager it tried to generate a lot of internal certs, and b)
it generates a lot of CRDs that I don't care about. But maybe those are addressable and I can
leave kong alone in this namespace and pretend it's not there, if I give the service an
external ip and get cilium to advertise it directly, then hang an external-dns name on it?
