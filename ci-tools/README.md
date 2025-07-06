# ci-tools (and Github Action notes)

## Github Actions

(Putting workflow commentary here so we do not confuse Github with extraneous files.)

### Validation - Purely-lexical

The goal is fast (to save money and dev time), stringent validation, with progressive
depth.

- Find all Helm and JSonnet directories in the repo
- Validate them lexically
- Template the output and run it through `kubeconform` to validate against the JSON schema

### VPN and Cluster Validation

If that works, the next step is to connect to the actual deployment network with a VPN
client and use `kubectl diff` to check the changes from the current status (as well
as some additional validation that the schema does not handle).

- In the Unifi UI I created a Wireguard VPN.
- Created a client config for `tales-github` (this produces a client cert and a config file)

Teh config file is of this form:

```
[Interface]
PrivateKey = ...
Address = 10.1.0.2/32
DNS = 10.1.0.1

[Peer]
PublicKey = ...
AllowedIPs = 0.0.0.0/0
Endpoint = ...:4443
```

- Edit the config file to replace `AllowedIPs = 0.0.0.0/0` with `AllowedIPs = 10.0.0.0/16,10.1.0.0/24` which is the top-level VLAN
  for the Unifi plus the VPN subnet itself (for DNS we hope). This avoids capturing non-local traffic into the VPN.
- Copy the config file into a 1Password secret `github-vpn-config` (for the future, when we might push this to Github using
  terraform or something)
- Copy the config file into a Github Action secret `WIREGUARD_CONF`
- Copy the pre-existing `kubeconfig` secret into a Github Action secret `KUBECONFIG`

TODO: Create a limited privs Service Account for the github runner and auth as that instead.
