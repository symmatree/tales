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

Update: Because there's special magic for openssh. You can get a look at it with

`op item get "jupyterhub-ssh-key"` which prompts you to (in this case)
`op item get cxchjmcc52fzphfoyr6dyrqnye --reveal` which shows the OpenSSH
format for the private key. Then `op item get cxchjmcc52fzphfoyr6dyrqnye --reveal --fields private\ key --format json` actually reveals the magic:

```
op item get cxchjmcc52fzphfoyr6dyrqnye --reveal --fields private\ key --format json
{
  "id": "private_key",
  "type": "SSHKEY",
  "label": "private key",
  "value": "-----BEGIN PRIVATE KEY-----\r\n...snip...=\r\n-----END PRIVATE KEY-----\r\n",
  "reference": "op://tales-secrets/jupyterhub-ssh-key/private key",
  "ssh_formats": {
    "openssh": {
      "reference": "op://tales-secrets/jupyterhub-ssh-key/private key?ssh-format=openssh",
      "value": "-----BEGIN OPENSSH PRIVATE KEY-----\n...snip...\n...snip...\n-----END OPENSSH PRIVATE KEY-----\n"
    }
  }
}                   
```

Note that both key formats are present (with json-escaped newlines). We could use `jq` to crack it out but that
reference format is what we need: `op read "op://tales-secrets/jupyterhub-ssh-key/private key?ssh-format=openssh" > ~/.ssh/id_jupyterhub`



- Started the Jupyterhub session, started a terminal inside it
- `sudo systemctl start ssh`
- Copied authorized_keys from /mnt/keys and set permissions.

```
eval `ssh-agent`
ssh-add ~/.ssh/id_jupyterhub
ssh jovyan@localhost -p8022
```

## In-container setup

Homedir actually persists unless explicitly wiped, so this is maybe not even per container.

- gh auth login and then clone semipro
- `sudo passwd jovyan` and set something easy (we disabled password auth in ssh)
- `./semipro/dotfiles/install.sh` (may require moving .gitconfig). Will need your password for chsh

Start the ssh server

- `sudo systemctl start ssh`

Activate 1password:

`eval $(op account add --address my.1password.com --email symmetry@pobox.com --signin)`

Launch VSCode tunnels (if you aren't using ssh to attach):

`DONT_PROMPT_WSL_INSTALL=1 code tunnel`

## Next Steps

- Automate authorized_keys and permissions stuff. Just mounting it into the home dir didn't work,
  probably because the home dir is generated on the fly? There's actual Jupyter Docker Stacks and
  jupyterhub setup stuff for hooking into their dir setup instead, in the helm chart maybe, I think rc.local or something.
