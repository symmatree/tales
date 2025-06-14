# jupyterhub

## What and Why

Features and stuff:

- Jupyter notebook servers in Kubernetes
- Managed per-user; currently I have a single server but allows a user to have
  multiple configurations (images and resource allocations primarily)
- Log in with Google for identity. Currently authorization is just lists of
  usernames in values.yaml. (Should be a group from Google but that's a whole Thing
  because Google OIDC doesn't provide group membership, and it gets tangled up
  with GAFYD and google enterprise stuff that I don't have.)
- Use any of the [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)
  images (or an image derived from them). Multiple server configs make it
  easier to resist the all-in-one image (though that's still what I do).
- Jupyter web UI allows terminal access to bootstrap and troubleshoot the pod as
  a remote dev machine. (In addition to actually running notebooks of course!)
- Via terminal, can run a VSCode Tunnel endpoint allowing VSCode `Remote-Tunnel` access.
  This allows Chromebook-based local or remote development with a fully-powered terminal,
  using the chosen identity provider (generally Github), through https://vscode.dev/. The
  tunnel requires in-network (or VPN of some kind) access to notebook.local.symmatree.com
  in order to establish it, but then is accessible remotely. Could be run as a quasi-service
  in the container like sshd but currently I prefer to explicitly set it up when needed
  (e.g. before going on a trip); a few minutes of VPN access suffice to enable it otherwise.
  NOTE that this only gives "vanilla" VSCode; Cursor is not allowed to use the Remote Tunnels
  extension or something like that.
  - Semi-related - the tunnel method also works from inside a WSL environment on Windows,
    where ssh-inbound is hard to get working. There is a native WSL VSCode extension but
    it repeatedly left a corrupt filesystem in the WSL VM, but tunnels work without damage.
    However this does not work for Cursor since it cannot use the WSL nor the Tunnel extensions.
- Passwordless SSH login to the per-user machine, interactively I guess, but specifically
  to enable VSCode `Remote-SSH` development. Keys managed through 1Password. This allows
  Cursor to connect. (This is pretty key - given the licensing around WSL and Remote Tunnels,
  it's hard to use Cursor for linux-based development without actually running a Linux box
  or a real VM. There may be a different approach but this was a major motivator in the ssh
  setup.)
- Software installed outside the home dir is transient (stored in the container's anonymous overlay
  filesystem) and will be replaced when the user stops and restarts the server (which deletes the pod).
  This allows testing a new config and then baking it into the Dockerfile and rebuilding.
- User's home dir is persistent unless explicitly deleted (by deleting the corresponding
  PersistentVolumeClaim). This allows dotfiles, `authorized_keys`, and ad hoc application configs
  of all kinds to persist independently of server lifetime (which in turn allows frequent
  rebuilds and updates of the underlying image).

I use an image based on one of the notebook images but with a set of tools pre-installed;
on top of that I simply clone and install my dotfiles as I would on a "real" machine.

## How

### Container privs

Runs as privileged container; it enables sudo and creates the `jovyan` user and
then drops down to NB_USER. This allows interactive sudo from the user, across notebooks,
ssh, and VSCode.

### Push / pull token

Assumes a single token with package read/write in GHCR, stored in
1password as `jupyterhub-github-token`.

This is created by `make-pull-token.sh` with the help of `image-pull-secret.jq`

This has to be run manually after the namespace has been created.

TODO: Get rid of manual step and package for reuse: https://github.com/symmatree/tales/issues/5

### ssh keys in 1Password and Client

Created a key in 1password. There's special magic for openssh. You can get a look at it with

`op item get "jupyterhub-ssh-key"` which prompts you to (in this case)
`op item get blahblah --reveal` which shows the OpenSSH
format for the private key. Then `op item get blahblah --reveal --fields private\ key --format json`
actually reveals the magic:

```
op item get blahblah --reveal --fields private\ key --format json
{
  "id": "private_key",
  "type": "SSHKEY",
  "label": "private key",
  "value": "<private-key-format>\r\n",
  "reference": "op://tales-secrets/jupyterhub-ssh-key/private key",
  "ssh_formats": {
    "openssh": {
      "reference": "op://tales-secrets/jupyterhub-ssh-key/private key?ssh-format=openssh",
      "value": "<openssh-private-key format>\n"
    }
  }
}
```

Connect with a config

```
cp ./jupyterhub/docker/ssh_config ~/.ssh/config
eval `ssh-agent`
ssh-add ~/.ssh/id_jupyterhub
ssh jovyan@notebook-ssh.local.symmatree.com
```

```
eval `ssh-agent`
ssh-add ~/.ssh/id_jupyterhub
ssh jovyan@notebook-ssh.local.symmatree.com
```

#### getting the keys on the client

Note that both key formats are present (with json-escaped newlines). We could use `jq` to crack it out but that
reference format is all we need for retrieval in venues where the 1password agent doesn't work: `op read "op://tales-secrets/jupyterhub-ssh-key/private key?ssh-format=openssh" > ~/.ssh/id_jupyterhub`

If connecting from a desktop machine, you can preferably install the 1Password SSH Agent,
and configure it to read from the Tales vault in addition to the others. (This is somewhere,
but I don't seem to have the .toml file the docs suggest I should, so TODO figure out how
I configured that.)

## Resetting Homedir

If you need to start clean, first use the File > Hub link from
`https://notebook.local.symmatree.com` to shut down your server,
then `k delete pvc claim-seth-porter-gmail-com---39d0c2f0` (or
equivalent for other users).

## Homedir keys and dotfile setup

Run this once, followed by the per-server-startup, below. After this you can clone
whatever repos you actually want to work on; this is just one-time plumbing for dotfiles.

- Copy authorized_keys from /mnt/keys and set permissions:

```
jovyan@jupyter-seth-porter-gmail-com---39d0c2f0:~$ mkdir -p ~/.ssh
jovyan@jupyter-seth-porter-gmail-com---39d0c2f0:~$ chmod 0700 ~/.ssh
jovyan@jupyter-seth-porter-gmail-com---39d0c2f0:~$ cp /mnt/keys/authorized_keys ~/.ssh
jovyan@jupyter-seth-porter-gmail-com---39d0c2f0:~$ chmod 0600 ~/.ssh/authorized_keys
jovyan@jupyter-seth-porter-gmail-com---39d0c2f0:~$ sudo systemctl start ssh
```

TODO: Automate authorized_keys and permissions stuff. https://github.com/symmatree/tales/issues/3

- `gh auth login` and then `gh repo clone semipro` (for dotfiles)
- `rm ~/.gitconfig`
- `eval $(op account add --address my.1password.com --email symmetry@pobox.com --signin)`
- `./semipro/dotfiles/install.sh`. Will need your password for `chsh`[^chsh]

[^chsh]:
    The chsh only partially works - the notebook login session already
    exists, so you'll need to run `zsh` manually (or `tmux attach` and
    choose a shell inside tmux) in Jupyter. However ssh should be producing
    a new login so it may take effect there (but would be lost at server
    restart).

## Per-server-startup

- Start the Jupyterhub session, started a terminal inside it
- `sudo systemctl start ssh`
- `sudo passwd jovyan` and set something easy (we disabled password auth in ssh)
- optional: `chsh zsh` - this only partially works (see below) but it saves having to
  run zsh manually in terminals in some cases. I don't usually bother, it's just in
  the install script so it works partially for a while until the first time I restart
  the server.
- Launch VSCode tunnels (if you aren't using ssh to attach): `code tunnel` - note this
  cannot be run under a VSCode terminal since they hijack `code` with a redirect to
  the ui. Simplest is to run it in a tmux session launched from the Notebook terminal.

This has to be done every time the server is recreated. (The ssh startup script
doesn't work right or something but this is sufficient to fix it.)

TODO: https://github.com/symmatree/tales/issues/6 - fix the startup bit

## Wishlist

- https://github.com/symmatree/tales/issues/7 - multiple users for ssh
- https://github.com/symmatree/tales/issues/8 - multiple servers per user
- https://github.com/symmatree/tales/issues/9 - factor docker stuff into another repo
