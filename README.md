# tales

Self-contained description of a Kubernetes cluster on Talos Linux within a Synology device

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

## Basic layout

I have a [Synology RS1619xs+](https://www.synology.com/en-us/products/RS1619xs+) from
a period of higher disposable income.

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
keep the control fixed as we scale. 