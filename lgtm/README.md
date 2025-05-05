# tales/lgtm

## Background

Loki, grafana etc. But I don't want to allocate my entire cluster just to documenting
itself. This is the motivation for minio however.

## Setup

This could be automated with `mc admin accesskey create` but for the moment


* I went to https://minio-console.local.symmatree.com:9443/access-keys and
    created a key named `loki-s3-creds`. Went to 1password and edited that entry
    to use the provided access key id and secret access key.
* I created three buckets, `loki-chunks`, `loki-ruler`, and `loki-admin`

## Debugging

Web UI for alloy is pretty useful, e.g.

```
k port-forward lgtm-alloy-logs-thzwl  12345:12345
```

Loki gives you metrics on 3100 but I haven't found
a debug UI:

```
k port-forward lgtm-loki-0 3100:3100
```
