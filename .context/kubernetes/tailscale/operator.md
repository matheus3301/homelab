Setting up the Kubernetes operator
Prerequisites
Tailscale Kubernetes Operator must be configured with OAuth client credentials. The operator uses these credentials to manage devices via Tailscale API and to create auth keys for itself and the devices it manages.

In your tailnet policy file, create the tags tag:k8s-operator and tag:k8s, and make tag:k8s-operator an owner of tag:k8s. If you want your Services to be exposed with tags other than the default tag:k8s, create those as well and make tag:k8s-operator an owner.


"tagOwners": {
  "tag:k8s-operator": [],
  "tag:k8s": ["tag:k8s-operator"],
}
You can use the visual policy editor to manage your tailnet policy file. Refer to the visual editor reference for guidance on using the visual editor.

Create an OAuth client in the Trust credentials page of the admin console. Create the client with Devices Core, Auth Keys, Services write scopes, and the tag tag:k8s-operator.

Installation
A default operator installation creates:

A "tailscale" Namespace.
An "operator" Deployment.
Role-based access control (RBAC) for the operator.
A "tailscale" IngressClass.
ProxyClass, Connector, ProxyGroup, DNSConfig, Recorder Custom Resource Definitions (CRDs).
There are two ways to install the Tailscale Kubernetes Operator: using Helm or applying static manifests with kubectl.

Helm
Tailscale Kubernetes Operator's Helm charts are available from two chart repositories.

The https://pkgs.tailscale.com/helmcharts repository contains well-tested charts for stable Tailscale versions.

Helm charts and container images for a new stable Tailscale version are released a few days after the official release. This is done to avoid releasing image versions with potential bugs in the core Linux client or core libraries.

The https://pkgs.tailscale.com/unstable/helmcharts repository contains charts with the very latest changes, published in between official releases.

The charts in both repositories are different versions of the same chart and you can upgrade from one to the other.

To install the latest Kubernetes Tailscale operator from https://pkgs.tailscale.com/helmcharts in tailscale namespace:

Add https://pkgs.tailscale.com/helmcharts to your local Helm repositories:


helm repo add tailscale https://pkgs.tailscale.com/helmcharts
Update your local Helm cache:


helm repo update
Install the operator passing the OAuth client credentials that you created earlier:


helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId="<OAauth client ID>" \
  --set-string oauth.clientSecret="<OAuth client secret>" \
  --wait