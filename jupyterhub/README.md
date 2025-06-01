# jupyterhub

Serving as `notebook.local.symmatree.com` because I don't like typing "jupyter".

Runs as privileged container; it enables sudo and then drops down to NB_USER.


## Push / pull token

Assumes a single token with package read/write in GHCR, stored in
1password as `jupyterhub-github-token`.

This is created by `make-pull-token.sh` with the help of `image-pull-secret.jq`

## ssh keys

Created a key in 1password. DL with command line didn't work but
export-as-openssh did (eventually?).

* Started the Jupyterhub session, started a terminal inside it
* `sudo systemctl start ssh`
* Copied authorized_keys to remote, increasingly manually and with a lot of manual permission changes.
* with `k port-forward -n jupyterhub jupyter-seth-porter-gmail-com---39d0c2f0 8022:22`
  I can then log in no-password after (on the client):

```
eval `ssh-agent`
ssh-add ~/.ssh/id_jupyterhub
ssh jovyan@localhost -p8022
```

## In-container setup

Homedir actually persists unless explicitly wiped, so this is maybe not even per container.

* gh auth login and then clone semipro
* `sudo passwd jovyan` and set something easy (we disabled password auth in ssh)
* `./semipro/dotfiles/install.sh` (may require moving .gitconfig). Will need your password for chsh

Start the ssh server

* `sudo systemctl start ssh`


## Next Steps

* Automate authorized_keys and permissions stuff. Just mounting it into the home dir didn't work,
  probably because the home dir is generated on the fly? There's actual Jupyter Docker Stacks and
  jupyterhub setup stuff for hooking into their dir setup instead, in the helm chart maybe, I think rc.local or something.
