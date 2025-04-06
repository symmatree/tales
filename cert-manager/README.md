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

We don't have a secrets injector yet, so we bootstrap with the 1password CLI and a manual secret: `cert-manager/install.sh`
