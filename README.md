# Terminfinder SH (Helm Charts for DVS)

Complete Helm Chart repository for deploying the Terminfinder to any kubernetes cluster (via Helm).

> These Helm charts are not compatible with Kubernetes <1.23, if you are enabling autoscaling.

## General Information

[CONTRIBUTING.md](./docs/CONTRIBUTING.md)

[SECURITY.md](./docs/SECURITY.md)

It's recommended to use a dedicated PostgreSQL instance for production usage.

## Local development

1. install and run minikube or other local K8s services https://kubernetes.io/docs/tasks/tools/
2. use scripts in installation below

## Installation

### Recommendations

* It's recommended to work with an ingress configuration, use `values.yaml` config for that.
* To use the ingress configuration, you need an ingress controller (
  e.g. [Nginx Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/))
* It's recommended to use a TLS connection at the ingress, therefore use the `tls` option in the Ingress definition.
* For usage of the TLS, you need to attach either manually an TLS cert via a secret, or
  use [cert-manager](https://cert-manager.io) for managing it via a cert-issuer (e.g. let's-encrypt).
* For communication between backend and postgres, we use a DNS entry. If you use Incluster-PostgreSQL instance, you need
  CoreDNS.
* For production usage, may use an own postgres instance. (Recommended, use
  the [Cloud Native PG Operator](https://cloudnative-pg.io) in Kubernetes)

### Installation steps

1. Prepare the value files.
2. Install the helm charts with `helm install ...` CLI Command:

```bash
# Create a namespace (or use default), where to work in:
$ kubectl create namespace terminfinder-demo

# First installing the helm chart, to the name
$ helm install terminfinder-demo terminfinder-chart -n terminfinder-demo

# Verify installation of helm charts:
$ helm list -n terminfinder-demo
$ kubectl get deploy -n terminfinder-demo
```

### Upgrade release

To upgrade the helm chart, use the `helm upgrade ...` command:

```bash
# Upgrade HelmChart
$ helm upgrade terminfinder-demo terminfinder-chart -n terminfinder-demo
```

### Debug Container

```bash
$ kubectl run -i --tty --rm debug --image=busybox -n terminfinder-demo --restart=Never
```

### Delete Release

To delete the helm chart (release), use the `helm uninstall...` command.

Note that the persistent volume may be available even if the helm release is uninstalled.

```bash
# Delete namespace
$ helm uninstall terminfinder-demo -n terminfinder-demo
$ kubectl delete pvc --all -n terminfinder-demo
$ kubectl delete namespace terminfinder-demo
```

## Using an own PostgreSQL DB instance

The helm chart deployment of the `terminfinder-frontend` will be kept untouched.

By default, an own instance of postgres is installed with the `terminfinder-backend` chart. You can disable by adding
the following configuration to you `values.yaml` of the backend helm installation:

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

With this secret already deployed, you can modify the helm chart deployment of the `terminfinder-backend` on these
values:

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
