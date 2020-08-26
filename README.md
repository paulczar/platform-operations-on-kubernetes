# Platform Operations on Kubernetes (POOK)

This project demonstrates how to set up and Platform Operations infrastructure on Kubernetes by providing a Reference Implementation of many platform level components such as CI, CD, Metrics, Logging, Policy Enforcement and security.

It was designed using Pivotal Container Service (PKS) as the Kubernetes provider with RBAC being provided by UAA, but the default environment should work on any Kubernetes cluster with advanced features like Oauth2/openid integration and DNS/Cert management requiring certain platform pieces provided by the underlying cloud.

We take advantage of a few tools to streamline things, firstly [Helm](https://helm.sh) as all of the infrastructure tooling is available in public Helm charts (although some charts may be vendored in here for custom changes). We use Helmfile to provide a wrapper over helm to allow for more complex installation workflows.

With the goal of doing a gitops style workflow for deploying this, it is expected that you'll have seperate `env` directory(s) containing the customizations for a particular environment or cluster.

For the most part you should just need to edit `envs/default/envs.sh` and fill it in with your details. This is a shell script that will export environment variables to be used by Helmfile. The reason for this is that if you have passwords/secrets you can store them outside of git and have the script extract them from wherever you keep them.

## Prerequisites

> Note: helmfile can use helm2 in tillerless mode, or helm3. Either way, there is no need to run tiller in your cluster.

It's expected that you already have the basic Kubernetes client tools like `kubectl` installed.

* [kubectl](https://kubernetes.io)
* [helm](https://helm.sh/docs/using_helm/#quickstart-guide)
* [helmfile](https://github.com/roboll/helmfile#installation)
* [helmdiff](https://github.com/databus23/helm-diff#install)

A happy script:

```bash
#!/bin/bash
helm init --client-only || echo "probably helm3"
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/rimusz/helm-tiller
wget -O ~/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.102.0/helmfile_linux_amd64
chmod +x ~/bin/helmfile
```


## Included Software

### Metrics and Observability

* Grafana
* Prometheus
* EFK (Elasticsearch, Fluentd, Kibana) or Loki + PromTail

### CI / CD

* Concourse
* Harbor
* Spinnaker

### Other

* Minio (for Spinnaker and Harbor artifacts)

## Example Deployment

### Default environment

This will deploy a default environment with no external auth or ingress set up.

See [docs/default/install.md](docs/default/install.md)

### OIDC/UAA environment

This will deploy an environment with Ingress, SSL, DNS, and UAA backed OIDC authentication for all apps.

See [docs/gcp-uaa-openid/install.md](docs/gcp-uaa-openid/install.md)


## Customizing Platform Operations on Kubernetes

Every Kubernetes cluster is different, just as every user of Kubernetes wants things installed differently. This gives us a fun challenge of needing to make it simple to deploy software, but also make the deployment flexible enough to suit most cases, and extendable for the rest.

Thankfully `helm` and `helmfile` give us the tools we need to do this. Utilizing `helmfile` allows us to build a gitops style system where we have a code repo (this one) and one or more environment repos that provides the environment specific details.

### Code Repo

In the Code Repo (this one) is a [helmfile.yaml](./helmfile.yaml) file that provides the fundamental work of installing our software by combining multiple helm charts together in an ordered and structured way.

Like Helm charts the `helmfile.yaml` can be treated as a template and values can be rendered into it. We can utilize this functionality and put most of our logic into a seperate values file.

The default set of values live in the [default environment](envs/default/values.yaml.gotmpl). This is used to specify which charts to install, their version, and the upstream Helm chart repository.

Also inside the Code Repo is a set of values files, each chart has its own directory with at least a default `values.yaml.tmpl` file. This file is the equivalent of an individual Chart's values file except it also can be rendered as a template. This allows us to amongst other things load in environment variables for passwords and secrets so that they are not stored in source control.

Each chart's values file can be overridden inside the primary values file by specifying an alternative location.

### Environment Repo

The default (and other generic examples) environment is found inside this repo under `envs/default`. This contains the default `values.yaml.tmpl` file as described above. It can be modified to enable/disable specific Charts or to change the upstream repository or version.

Also in the environment repo is an `envs.sh` file. This is a source file written in bash that contains exportable environment variables to further configure the environment. Values can be stored directly in this file, or they can be programmatically loaded from external sources.

If you need to even further customize a chart you could copy that chart's `values.yaml.tmpl` file from the code repo into the environment repository and then modify it to suit. This gives you complete configurability of the Chart if you need it.
