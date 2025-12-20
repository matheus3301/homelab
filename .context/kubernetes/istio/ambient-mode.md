Install with Helm
 6 minute read     page test

Follow this guide to install and configure an Istio mesh with support for ambient mode. If you are new to Istio, and just want to try it out, follow the quick start instructions instead.
We encourage the use of Helm to install Istio for production use in ambient mode. To allow controlled upgrades, the control plane and data plane components are packaged and installed separately. (Because the ambient data plane is split across two components, the ztunnel and waypoints, upgrades involve separate steps for these components.)

Prerequisites
Check the Platform-Specific Prerequisites.

Install the Helm client, version 3.6 or above.

Configure the Helm repository:

$ helm repo add istio https://istio-release.storage.googleapis.com/charts
$ helm repo update

Install the control plane
Default configuration values can be changed using one or more --set <parameter>=<value> arguments. Alternatively, you can specify several parameters in a custom values file using the --values <file> argument.

You can display the default values of configuration parameters using the helm show values <chart> command or refer to Artifact Hub chart documentation for the base, istiod, CNI, ztunnel and Gateway chart configuration parameters.
Full details on how to use and customize Helm installations are available in the sidecar installation documentation.

Unlike istioctl profiles, which group together components to be installed or removed, Helm profiles simply set groups of configuration values.

Base components
The base chart contains the basic CRDs and cluster roles required to set up Istio. This should be installed prior to any other Istio component.

$ helm install istio-base istio/base -n istio-system --create-namespace --wait

Install or upgrade the Kubernetes Gateway API CRDs
Note that the Kubernetes Gateway API CRDs do not come installed by default on most Kubernetes clusters, so make sure they are installed before using the Gateway API:

$ kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

istiod control plane
The istiod chart installs a revision of Istiod. Istiod is the control plane component that manages and configures the proxies to route traffic within the mesh.

$ helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait

CNI node agent
The cni chart installs the Istio CNI node agent. It is responsible for detecting the pods that belong to the ambient mesh, and configuring the traffic redirection between pods and the ztunnel node proxy (which will be installed later).

$ helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait

Install the data plane
ztunnel DaemonSet
The ztunnel chart installs the ztunnel DaemonSet, which is the node proxy component of Istio’s ambient mode.

$ helm install ztunnel istio/ztunnel -n istio-system --wait

Ingress gateway (optional)
Istio supports the Kubernetes Gateway API and intends to make it the default API for traffic management in the future. If you use the Gateway API, you do not need to install and manage an ingress gateway Helm chart as described below. Refer to the Gateway API task for details.
To install an ingress gateway, run the command below:

$ helm install istio-ingress istio/gateway -n istio-ingress --create-namespace --wait

If your Kubernetes cluster doesn’t support the LoadBalancer service type (type: LoadBalancer) with a proper external IP assigned, run the above command without the --wait parameter to avoid the infinite wait. See Installing Gateways for in-depth documentation on gateway installation.

Configuration
To view supported configuration options and documentation, run:

$ helm show values istio/istiod

Verify the installation
Verify the workload status
After installing all the components, you can check the Helm deployment status with:

$ helm ls -n istio-system
NAME            NAMESPACE       REVISION    UPDATED                                 STATUS      CHART           APP VERSION
istio-base      istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    base-1.28.1     1.28.1
istio-cni       istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    cni-1.28.1      1.28.1
istiod          istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    istiod-1.28.1   1.28.1
ztunnel         istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    ztunnel-1.28.1  1.28.1

You can check the status of the deployed pods with:

$ kubectl get pods -n istio-system
NAME                             READY   STATUS    RESTARTS   AGE
istio-cni-node-g97z5             1/1     Running   0          10m
istiod-5f4c75464f-gskxf          1/1     Running   0          10m
ztunnel-c2z4s                    1/1     Running   0          10m

Verify with the sample application
After installing ambient mode with Helm, you can follow the Deploy the sample application guide to deploy the sample application and ingress gateways, and then you can add your application to the ambient mesh.

Uninstall
You can uninstall Istio and its components by uninstalling the charts installed above.

List all the Istio charts installed in istio-system namespace:

$ helm ls -n istio-system
NAME            NAMESPACE       REVISION    UPDATED                                 STATUS      CHART           APP VERSION
istio-base      istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    base-1.28.1     1.28.1
istio-cni       istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    cni-1.28.1      1.28.1
istiod          istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    istiod-1.28.1   1.28.1
ztunnel         istio-system    1           2024-04-17 22:14:45.964722028 +0000 UTC deployed    ztunnel-1.28.1  1.28.1

(Optional) Delete any Istio gateway chart installations:

$ helm delete istio-ingress -n istio-ingress
$ kubectl delete namespace istio-ingress

Delete the ztunnel chart:

$ helm delete ztunnel -n istio-system

Delete the Istio CNI chart:

$ helm delete istio-cni -n istio-system

Delete the istiod control plane chart:

$ helm delete istiod -n istio-system

Delete the Istio base chart:

By design, deleting a chart via Helm doesn’t delete the installed Custom Resource Definitions (CRDs) installed via the chart.
$ helm delete istio-base -n istio-system

Delete CRDs installed by Istio (optional)

This will delete all created Istio resources.
$ kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete

Delete the istio-system namespace:

$ kubectl delete namespace istio-system

Generate a manifest before installation
You can generate the manifests for each component before installing Istio using the helm template sub-command. For example, to generate a manifest that can be installed with kubectl for the istiod component:

$ helm template istiod istio/istiod -n istio-system --kube-version {Kubernetes version of target cluster} > istiod.yaml

The generated manifest can be used to inspect what exactly is installed as well as to track changes to the manifest over time.

Any additional flags or custom values overrides you would normally use for installation should also be supplied to the helm template command.
To install the manifest generated above, which will create the istiod component in the target cluster:

$ kubectl apply -f istiod.yaml

If attempting to install and manage Istio using helm template, please note the following caveats:

The Istio namespace (istio-system by default) must be created manually.

Resources may not be installed with the same sequencing of dependencies as helm install

This method is not tested as part of Istio releases.

While helm install will automatically detect environment specific settings from your Kubernetes context, helm template cannot as it runs offline, which may lead to unexpected results. In particular, you must ensure that you follow these steps if your Kubernetes environment does not support third party service account tokens.

kubectl apply of the generated manifest may show transient errors due to resources not being available in the cluster in the correct order.

helm install automatically prunes any resources that should be removed when the configuration changes (e.g. if you remove a gateway). This does not happen when you use helm template with kubectl, and these resources must be removed manually.