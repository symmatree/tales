# jupyterhub

Serving as `notebook.local.symmatree.com` because I don't like typing "jupyter".

Runs as privileged container; it enables sudo and then drops down to NB_USER.


## Push / pull token

Assumes a single token with package read/write in GHCR, stored in
1password as `jupyterhub-github-token`.

This has fields `username` and `password` which were manually set
by me. This pasted this

```

```
