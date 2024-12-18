# Terminfinder SH (Helm Charts for DVS)

Complete Helm Chart repository for deploying the Terminfinder to any kubernetes cluster (via Helm).

> These Helm charts are not compatible with Kubernetes <1.23, if you are enabling autoscaling.

## General Information

Licensed under the EUPL 1.2

Copyright © 2022-2023 Dataport AöR

[CONTRIBUTING.md](./docs/CONTRIBUTING.md)

[SECURITY.md](./docs/SECURITY.md)

It's recommended to use a dedicated PostgreSQL instance for production usage.

## Local development

1. install and run minikube or other local K8s services https://kubernetes.io/docs/tasks/tools/
2. use scripts in installation below

### Minikube

```bash
minikube addons enable ingress
minikube tunnel
```

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

### Using an own PostgreSQL DB instance

The helm chart deployment of the `terminfinder-frontend` will be kept untouched.

By default, an own instance of postgres is installed with the `terminfinder-backend` chart. You can disable by adding
the following configuration to you `values.yaml` of the backend helm installation:

```yaml
terminfinder-backend:
  externalDatabase:
  enabled: true
  address: <your-custom-value>
  port: <your-custom-value>
  database: <your-custom-value>
  username: <your-custom-value>
  existingSecret: terminfinder-backend-custom-postgresql
  secretKeys:
    userPasswordKey: key

  postgresql:
    enabled: false
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
  key: "secret"
```

#### Enable uuid-ossp extention

A prerequisite for running the terminfinder backend is the postgresql extension `uuid-ossp`, which can be enabled by
running the command as db-admin:

```
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
ALTER EXTENSION "uuid-ossp" SET SCHEMA public;
```

### Installation & upgrade steps

1. Prepare the value files.
2. Install the helm charts with `helm install ...` CLI Command:

```bash
helm upgrade --install -n tf --create-namespace tf1 terminfinder-chart
helm list -n tf
watch kubectl get pod,deploy,pvc,svc,ing,ep -n tf
```

### Debug Container

```bash
$ kubectl run -i --tty --rm debug --image=busybox -n terminfinder-demo --restart=Never
```

### Delete Release, pvc, and namespace

To delete the helm chart (release), use the `helm uninstall...` command.

Note that the persistent volume may be available even if the helm release is uninstalled.

```bash
$ helm uninstall tf1 -n tf
$ kubectl delete pvc --all -n tf
$ kubectl delete namespace tf
```
