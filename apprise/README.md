# apprise - notification API

https://github.com/caronc/apprise-api/tree/master

## Why

I want two tiers (at least) of notification delivery and robustness.

* For key services
  (and for things themselves in the notification path) I want to get off-site as soon as
  possible, ideally without needing to reach out to anything else.
* For most notifications, and for the common-case even for key services, I want
  to go through a centralized collect/dispatch point. Trivially, I don't want to
  have to change my phone number in 20 different apps that I want to send me texts.
  (I don't even want them to know my number - just a webhook to pass along to.)

### Key Services

For the key services, there are two good patterns using Apprise:

* Call it directly as a CLI or even a library, with a config injected from a secret.
  (The config has to be pre-injected into each leaf service because otherwise it might
  not be able to call for help.)
* Use a "sidecar" container to run the AppRise API service in the same pod. This
  is a little nicer in terms of isolation (because the sensitive parts of the AppRise
  config aren't exposed to the notification sender - it just hits a port), but it
  adds a little complexity and a separate process which might be dead for some
  more-or-less-correlated reason.

Both of these are reasonable, depending on how easy it is to add binaries and config
to the main environment, versus adding a sidecar container; they offer roughly
equivalent levels of security and robustness. (In both cases, the notifier has pretty
direct access to things like your cell phone number - which is necessary because it
needs to be able to call it all by itself.)

### Most services

For most services, this is unnecessary robustness, and doesn't make up for the
necessity this brings of having to update the config for each such service in order
to change any aspect of notifications. (Hopefully in a mechanical way, but it's at
least a piece of complexity and a possibile point for a subtle breakdown.)
And for the key services, it's nice to be able to route and aggregate their
notifications through the same channel as everyone else.

So, this namespace provides a shared apprise-api service, both for the common
path and as a way to proof out config before pushing it to the key services
through a secret.
