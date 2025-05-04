# tales/cert-manager

* Requires cilium
* Requires the gateway CRDs we installed alongside cilium.
* Requires a service account for the DNS solver

## One-time: Service account setup

```
export PROJECT_ID=symm-custodes
gcloud iam service-accounts create dns01-solver --display-name "dns01-solver"
gcloud projects add-iam-policy-binding $PROJECT_ID \
   --member serviceAccount:dns01-solver@$PROJECT_ID.iam.gserviceaccount.com \
   --role roles/dns.admin
gcloud iam service-accounts keys create key.json \
   --iam-account dns01-solver@$PROJECT_ID.iam.gserviceaccount.com
```

I then made a Secure Note in 1Password, in my dedicated vault for this cluster,
named "cert-manager/clouddns-sa", which we can manually forward into a secret:

## Namespace setup and initial secret

Main install is `kubectl apply -f cert-manager/application.yaml` which will then get everything.

I've taken some pains (especially with minio) to reduce the number of root certs and concentrate
on one Issuer (actually ClusterIssuer) of each type - "real", staging, and self-signed. This is because
we need to trust those roots on the client machines, if the cert requests involve names that the
real signer won't touch, and that's a manual process on Windows. Keeping them as ClusterIssuers
means their secrets are all in the `cert-manager` namespace so the `trust-manager` bundles can
access them without need to be able to read all secrets globally. (Though I think then we did
have to grant that privilege in order to *write* to secrets, which isn't needed - public keys
aren't secret!!! - but is what a lot of clients expect, such as minio.)

## Trust the cert on Ubuntu (e.g. WSL)

```
set -o pipefail
kubectl get secret tales-ca-tls -n cert-manager \
  -o jsonpath="{.data.tls\.crt}" \
  | base64 -d \
  | sudo tee /usr/local/share/ca-certificates/tales-ca-tls.crt \
&& sudo update-ca-certificates
```

## Trust the cert in a container

Often there's a way to provide a CA cert in e.g. values.yaml,
which can be coupled with trust-manager to inject the cert as 
a ConfigMap (preferable) or a secret.

But if you need to trust it at the OS level rather than the application,
or that mechanism doesn't exist: then it depends on the OS. In many cases
just the Ubuntu setup, above (as a mount rather than a literal file).

For `distroless`, [example](https://github.com/symmatree/tales/blob/main/lgtm/values.yaml#L98):
mount in a particular place, point at it with env var.

## Trust the cert in Windows

The same `.crt` file can be installed on Windows using the `Certificates`
`mmc.exe` snap-in to install to trusted roots for both the user and
the local computer.
