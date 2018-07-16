# Open Data Cube on JupyterHub using Kubernetes

This is a work in progress.

Tools you need to deploy this include:
 * Kops
 * Kubectl
 * Helm
 * aws command line.

Other technology you need to know about in order to deploy include [Kubernetes](https://kubernetes.io/), [Jupyterhub](https://github.com/jupyterhub/jupyterhub), [AWS](https://aws.amazon.com/) and [Open Data Cube](https://www.opendatacube.org/).

## How to deploy

In order to create a deployment of JupyterHub with Open Data Cube, you first need to create a Kubernetes cluster. Then you deploy the charts that represent the JupyterHub system, and that uses a Docker image that supports Open Data Cube.

The specifics of these deployment steps are contained in the Makefile.



*Please note that this is a work in progress, and may need further work to be production ready.*