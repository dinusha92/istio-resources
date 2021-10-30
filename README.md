# istio-resources
This repository contains Istio resources from installation to covering use cases of istio.

## Install istio

Istio can be installed in 2 ways.

1. Using istioctl
2. Using manifest files

This intructions guides you to install Istio demo profile using manifest files.

Clone the repository

# [SSH](#tab/tab-id-1)
```
git clone git@github.com:dinusha92/istio-resources.git
```

Navigate inside the root directory of the downloaded project.
```
cd istio-resources
```
Apply the manifest yamls on the Kubernetes cluster.

```
kubectl apply -f .
```
Verify the status of the Istio installation by checking if the pods are in the READY state as shown belowe.
```
kubectl get pods -n istio-system

#You should see a similar output as shown below.
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-5f8b47cfc-b7xpr     1/1     Running   0          105s
istio-ingressgateway-64b7899489-dpltx   1/1     Running   0          105s
istiod-5d9bbb9cb4-mkc6n                 1/1     Running   0          105s

```
Installing addons.
- Addons are not mandatory, but supportive artifacts for the service mesh. You can find manifest files for each addon using the link below.
    - [Istio addons](https://istio.io/latest/docs/ops/integrations/) 


