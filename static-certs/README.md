# static-certs

This folder contains various one-off certs that are not associated with
an ingress. Just leveraging `cert-manager` to manage some certs for
external resources in my home network.

## Manual operation

Until I decide which Unifi-scripting mechanism I hate least, I can just
pull the cert and key manually every month:

```
k get secret -n static-certs morpheus-cert -o jsonpath="{.data['tls\.crt']}" | base64 --decode > morpheus-cert.crt
k get secret -n static-certs morpheus-cert -o jsonpath="{.data['tls\.key']}" | base64 --decode > morpheus-cert.key
k get secret -n static-certs raconteur-cert -o jsonpath="{.data['tls\.crt']}" | base64 --decode > raconteur-cert.crt
k get secret -n static-certs raconteur-cert -o jsonpath="{.data['tls\.key']}" | base64 --decode > raconteur-cert.key
```
