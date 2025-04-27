# tales

Self-contained description of a Kubernetes cluster on Talos Linux within a Synology device

## Links

This is my project so I'm putting convenience links here for myself, sorry!

* [Morpheus (unifi controller) `https://morpheus.local.symmatree.com`](https://morpheus.local.symmatree.com)
* [Kubernetes Dashboard `https://dashboard.local.symmatree.com`](https://dashboard.local.symmatree.com/#/workloads?namespace=_all)
* [ArgoCD `https://argocd.local.symmatree.com`](https://argocd.local.symmatree.com)
* [Google Cloud DNS `local.symmatree.com`](https://console.cloud.google.com/net-services/dns/zones/local-symmatree-com/details?project=symm-custodes)
* [`talos-control-1` Talos serial console](https://raconteur.ad.local.symmatree.com:5001/webman/3rdparty/Virtualization/noVNC/vnc.html?autoconnect=true&reconnect=true&path=synovirtualization/ws/967c994c-c0b0-46db-a5d9-5efe7fe97d6d&title=talos-control-1&app_id=02356b89-847c-469b-b105-3a88664f5eb4&kb_layout=en-us&v=2.7.0-12229&app_alias=)
* [`talos-worker-1` Talos serial console](https://raconteur.ad.local.symmatree.com:5001/webman/3rdparty/Virtualization/noVNC/vnc.html?autoconnect=true&reconnect=true&path=synovirtualization/ws/b23b2210-0da4-42a4-b6c9-1ba32fa4013e&title=talos-worker-1)

## Caveats

This is a personal project. I have attempted to isolate "all" the configuration and setup
for initializing this homelab kubernetes cluster from scratch, with the secrets
safely extracted (I hope - also none of this is exposed to the internet).
I try to keep things relatively safe but this is not a high security installation
and I am not a security professional, so do your own assessment.

Feel free to use this repository for inspiration or directly use things you find
helpful, and let me know if it ends up being handy or damaging!

## Reuse and goals

Currently I have no intention of directly reusing this repo as a library; I would fork
it if I wanted a second, similar cluster. I plan to factor out as much configuration
as I can so that eventually this repo is only declaring the intent, in terms of what
components and applications I want to run in this cluster, rather than trying to figure
out how to reuse the cluster description itself. But each individual application will
probably go through an abstraction flow from being directly configured here (or even
in a UI), to being abstracted out into a new or existing set of libraries and being
incorporated here by reference.

Procedurally, I'm starting from various fragmented experiments and configs across
several repos, trying to bring them together in a self-container environment that
can stand up the cluster from zero. I have no objection to manual operations as
long as they're clear and relatively rare, but they should be for moments that
are fundamentally policy ("I want to take a named backup at this moment in time")
not to replace automation ("I haven't taken a backup in a while, I guess I should").

## Basic layout

I have a [Synology RS1619xs+](https://www.synology.com/en-us/products/RS1619xs+) from
a period of higher disposable income. It has an unreasonable amount of compute to
be left to just be a NAS. It also has an internal software environment that is based
on Linux, but with enough local changes and configuration that it is hard (and explicitly
discouraged!) to interact with it at that level. So the idea now is to use VMs to
run a completely independent software environment, letting the synology focus on
storage and on actually supported use-cases that Synology spends time on, like
storing surveillance video, providing a central backup point, and so forth.

### Alternative: "Container Manager" (Docker)

Historically I have tried various management
strategies using Synology's [Docker integration](https://www.synology.com/en-us/dsm/feature/docker),
but both the software and the kernel are quite old. You can upgrade them in various
less-than-supported ways, but this is messing with the Synology innards when the whole
point of a NAS (versus a "server with a lot of storage") is that it Just Works. Empirically,
the built-in stuff works very well for simple "just run this image" kinds of deployments, either
mounting a single data drive in some obvious way, or better yet for things that just live
semi-statelessly in the container filesystem (and don't mind being wiped). If the image exposes
ports, you can connect them to the Synology serving stuff, either mounting them in a shared URL-space or
serving them as a virtual host (synology reverse proxies to the docker-exposed port).

There's some basic docker-compose support (with a rather older version of docker-compose
itself, IIRC - that was one of the early ad hoc upgrades I tried, unfortunately bringing
the system further and further from any kind of Synology-stock). After upgrades, I could
use this to do more configuration from code. To make that work, I would ssh into the synology,
check out the configuration git repo, and then use the UI to import from that path. All of this is bad:

* normalizing sshing into the NAS
* having to define a scratch space for the repo, or a persistent one for that matter. This was confused additionally because I was trying to host the repo on the same machine in almost the same place, and I repeatedly swapped the paths in command lines, treating the master as the checked-out client and vice versa.
* having to mess with the docker installation just to get a usable version of docker-compose. This may be obsolete but it's hard to even tell how to revert correctly.

## current: VMs

Current lay down is 2 VMs, one control plane and one worker, planning to make the worker larger but
keep the control fixed as we scale. (Alternative would be to use a single machine to avoid the slack
space of using 2 VMs, but I feel like I'll want a dedicated control plane more and more if I add
additional worker nodes, and I've got at least one NUC I want to add.)

There doesn't seem to be a nice JSON format or anything for the VMs (it will import OVA files but
that's pretty elaborate for a short definition), but it seems to be relatively insensitive - except
for attempting a control plane node with only 1G of ram, every configuration has booted and been
able to see storage and network.

Currently a synology host running `DSM 7.2.2-72803`, and Virtual Machine Manager `2.7.0-12something` (if they
won't make the text selectable, I won't bother copying their too-long version strings).

Common settings:

* Video card: `vmvga` but I have no examples where it was observably different from `vga`
* Machine type: `Q35` which I think is a kind of Lexus. I have no context on this one but a newer abstraction seems useful.
* Storage: 100 GB disk, without space reclamation, attached as Virtual Disk 1 to be the OS install disk. VirtIO Scsi Controller selected.
* Network: "Default VM Network" 
* ISO for bootup: SEE [talos/README.md](talos/README.md)
* Autostart: Last State
* Boot from: For first boot, DVD/CDROM. You will have to change this to Virtual Hard Drive after Talos is installed. (Once installed to the OS, Talos will refuse to boot from the ISO, to avoid killing a live install.)
* Firmware: Legacy BIOS. Both work. Only concrete difference observed is [as documented](https://www.synology.com/en-global/dsm/7.2/software_spec/vmm), "When the virtual machine firmware is UEFI, the maximum resolution is 800x600". Whereas the Legacy BIOS setting, combined with the hokey `vga=` kernel parameter, is the only way I succeeded in getting reasonably high resolution text on the "dashboard" shown on the "physical console" (which is what you when you click "Connect" from the Synology view of the VMs)

The "vga" kernel parameter bit is [documented under the interactive dashboard](https://www.talos.dev/v1.9/talos-guides/interactive-dashboard/)
with a link to the unpromising-looking ["What is vesafb?" page](https://docs.kernel.org/fb/vesafb.html) but in fact it works. To
get 1024x768, pick the "16M" (32-bit color) option, 0x118, add 0x200 to get 0x318, convert to decimal as 792, and add `vga=792` to
the kernel command line does in fact change the resolution, while doing what it suggests (`gfx_mode` and friends) does not work.
795 (1280x1024x32) also works! The console dashboard isn't a huge deal but it's useful; in good old 80x25 text mode you really can't see any logs. At 800x600 in UEFI
it was usable, but higher is better.

## Operations Notes

### Shutting Down / Rebooting

Via the Synology UI: The host and VM are supposed to send / catch ACPI events and shut down somewhat gracefully if you click Shutdown in the 
Synology UI. Better once we install the guest agent as a daemonset. This is the only way to shut down if you have lost credentials at the talos level.

Via Talos: for example `talosctl reboot -n 10.0.1.100` for the worker. Should guarantee an orderly shutdown one hopes. However this does not ACTUALLY
reboot the machine, it only `kexec`s the kernel again, so it does not apply changed kernel parameters.

### Catching a reboot

In the current setup there is a pause for a few seconds at bootup. From the Synology UI you can wait until the text changes from "Powering On"
to "Running" before clicking Connect. (You can click earlier, then keep clicking Connect in the KVM until it works, but the text change
saves you from having to click blindly.) At that point you're in a grub menu in the KVM and you can hit up/down arrow to stop the timer.

### Resetting

```
talosctl reset -n 10.0.1.100
talosctl reset -n 10.0.1.50 --graceful=false
```

Sometimes you just want to start over. On a given node, `talosctl reset` is kind of like `kubeadm reset`, it mostly removes the state on the node
itself, but if you tell it to be graceful then it will exit the cluster first. (Otherwise you'll need to delete the node yourself in Kubernetes
and possibly some dangling resources like local PVs and things.)

An alternative from the Talos docs is to do "a same-version upgrade" which is required for things like changing kernel parameters IIRC, but
seems to be pretty close to a clean install, versus making config changes and patching them incrementally on a live system. But of course
the whole intent of talos is to keep everything very strongly tied to the config, so I worry a lot less about drift than I would when I was,
for example, directly installing and upgrading containerd packages on a server.

That said, "talosctl reset" is how you get past the "can't boot off the ISO with an installed config on disk" blocker to start over completely
from an ISO image. (You could go even further and actually delete the disk on the VM level, then create and attach a replacement, being sure
to put it first in order, but this is already plenty.)

If you deleted the config and don't have the keys to connect to talos, or the networking is broken in a fundamental way or something, you can
instead trigger a reset interactively at the GRUB menu - you have to trigger a reboot using the VM controls in Synology, then "catch" the
menu and startup and choose to reset. 

Note: Once the reset is complete, the drives will be wiped and you'll need to change back to boot once from CD-ROM ISO image again.

### Bootstrapping Notes

I keep iterating on the best way to bring things up from scratch.

```graphviz
argocd -> cert_manager_annotation;
argocd -> cilium;
cert_manager -> onepassword;
cilium -> cert_manager_annotation;
external_dns -> onepassword;
kube_dashboard -> external_dns_annotation;
kube_dashboard -> cert_manager;

```

argocd should have a dependency on a secret for a github secret but that's manual right now.

onepassword currently doesn't use an ingest. It would have cert_manager and cilium deps for that.

Newest deploy plan:

* Talos control plane
* Install cilium via helm templating
  * Will complain about Certificate being unknown CRD but it will install the basic CNI
* Install Argocd via helm templating
  * References various uninstalled stuff but via annotations; this is why the ingress won't work yet
* If needed, talk to argocd via command line -> ui (but not yet ingress)
* Install auto-sync Applications for cilium and Argocd, replacing the manual installs.
* Connect (onepassword) via install.sh which is just some scripted bootstrap secrets then an application.yaml
* Cert-manager via application.yaml
* external-dns via application.yaml
* Redeploy Hubble UI, anyone else who needed secrets. Usually a couple of "Replace" rounds in here.
* Reboot
* Add worker
* Reboot worker
* kubernetes-dashboard via application.yaml
* static-certs via application.yaml
* directpv to deploy to worker
* minio-operator via application.yaml
* tales-tenant via application.yaml

### Troubleshooting

* https://isovalent.com/blog/post/its-dns/ has a nice writeup of hubble for DNS


FREAKING DNS.

Okay to be fair it turned out not to be DNS per se, but rather that we were
not successfully ARPing for pod addresses so they could send but not receive
anything (except for outside 10.x, since that was where IP Masquerading kicked
in and it all started working again.)
