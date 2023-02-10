# Terminfinder SH (Helm Charts for DVS)

Complete Helm Chart repository for deploying the Terminfinder to any kubernetes cluster (via Helm).

> These Helm charts are not compatible with Kubernetes <1.23, if you are enabling autoscaling.

## General Information

[SECURITY.md](./SECURITY.md)

## Components

* Frontend: `registry.opencode.de/ig-bvc/demo-apps/terminfinder-sh/terminfinder-sh-frontend:v2.2.0`
* Backend: `registry.opencode.de/ig-bvc/demo-apps/terminfinder-sh/terminfinder-sh-backend:V1.0.9`
* Postgres (part of Backend): Using [this public Helm chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql/) as fundament, but can be disabled through `values.yaml` of the backend file.

Please modify the `values.yaml` files or use the CLI method for deployment and configuration. It's recommended to use an dedicated PostgreSQL instance for production usage.

## Installation

### Recommendations

* It's recommended to work with a ingress configuration, use `values.yaml` config for that.
* To use the ingress configuration, you need a ingress controller (e.g. [Nginx Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/))
* It's recommended to use a TLS connection at the ingress, therefore use the `tls` option in the Ingress definition.
* For usage of the TLS, you need to attach either manually an TLS cert via an secret, or use [cert-manager](https://cert-manager.io) for managing it via a cert-issuer (e.g. let's-encrypt).
* For production usage, may use an own postgres instance. (Recommended, use the [Cloud Native PG Operator](https://cloudnative-pg.io) in Kubernetes)

### Installation steps

1. Prepare the value files for the backend and frontend each.
2. Install the helm charts with `helm install ...` CLI Command

```bash
# Create a namespace (or use default), where to work in:
$ kubectl create ns terminfinder-demo

# First installing the helm chart, to the name
$ helm install terminfinder-backend ./charts/terminfinder-backend -n terminfinder-demo -f demo-backend.values.yaml

# Second installing the helm chart of the frontend
$ helm install terminfinder-frontend ./charts/terminfinder-frontend -n terminfinder-demo -f demo-frontend.values.yaml

# Verify installation of helm charts:
$ helm list -n terminfinder-demo
$ kubectl get deploy -n terminfinder-demo

# Go to your configured ingress host domain (e.g. terminfinder.open-code.local) and test it out!
# The URL of the ingresses you can get here:
$ kubectl get ingress -n terminfinder-demo
```

Your can upgrade the helm chart as usually with `helm upgrade ...` command.

### Using a own PostgreSQL DB instance

The helm chart deployment of the `terminfinder-frontend` will be kept untouched.

By default a own instance of postgres is install with the `terminfinder-backend` chart. You can disable by adding the following configuration to you `values.yaml` of the backend helm installation:

```yaml
postgresql:
  enabled: false

  # Or configure it with the docs here:
  # https://github.com/bitnami/charts/tree/main/bitnami/postgresql#parameters
```

Additionally, you should store credentials (of db user password) into a secret like that:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: terminfinder-backend-custom-postgresql
  namespace: terminfinder-demo
  labels:
    app.kubernetes.io/name: postgresql
type: Opaque
data:
  customPasswordKey: "eW91LWtub3ctaG93LWl0LXdvcmtzLSN0aGVsw6RuZAo="
```

With this secret already deployed, you can modify the helm chart deployment of the `terminfinder-backend` on this values:

```yaml
global:
  postgresql:
    auth:
      username: <your-custom-username>
      # password: this-is-not-secure-for-production!
      database: <your-custom-database>
      existingSecret: terminfinder-backend-custom-postgresql # or how you secret is called
      secretKeys:
        userPasswordKey: customPasswordKey # the key of the secret, where the password is saved
```
