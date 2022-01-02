# istio-resources
This repository contains Istio resources from installation to covering use cases of istio.

The current installation are artifacts are created for Istio version 1.11.

### Install istio

Istio can be installed a couple of [ways](https://istio.io/v1.11/docs/setup/install/).

This intructions guides you to install Istio demo profile using manifest yaml files.

Clone the repository

# [SSH](#tab/tab-id-1)
```
git clone git@github.com:dinusha92/istio-resources.git
```

Navigate inside the root directory of the downloaded project and then navigate inside *istio-installation/istio* directory.
```
cd istio-resources/istio-installation/istio
```
Apply the manifest yamls on the Kubernetes cluster.

```
kubectl apply -f .
```
Verify the status of the Istio installation by checking if the pods are in the READY state as shown belowe.
```
kubectl get pods -n istio-system
```
You should see a similar output as shown below.

```
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-5f8b47cfc-b7xpr     1/1     Running   0          105s
istio-ingressgateway-64b7899489-dpltx   1/1     Running   0          105s
istiod-5d9bbb9cb4-mkc6n                 1/1     Running   0          105s
kiali-787bc487b7-tskzx                  1/1     Running   0          24m
prometheus-9f4947649-lt9j5              2/2     Running   0          9m29s

```

### Accessing Services

How to access the portals.

When you list the services in the *istio-system* namespace, you will see an output similar to below.

```
kubectl get svc -n istio-system
```

```
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.111.128.21    <none>        80/TCP,443/TCP                                                               154m
istio-ingressgateway   LoadBalancer   10.110.87.74     <pending>     15021:31615/TCP,80:30563/TCP,443:30339/TCP,31400:32074/TCP,15443:31778/TCP   154m
istiod                 ClusterIP      10.105.154.204   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        154m
kiali                  NodePort       10.105.0.75      <none>        20001:32000/TCP,9090:30477/TCP                                               20m
prometheus             ClusterIP      10.104.140.57    <none>        9090/TCP                                                                     6m8s

```

Note: If you are using minikube, you will not see a EXTERNAL-IP for the istio-ingressgateway even though the service type is LoadBalancer. Use the ***minikube ip*** command to get the IP. With that, user the node port associated for the specific protocol. In the above listing, the port 80 -> 30563 and 443 -> 30339. This may vary on your deployment.


Out of the above services, we will use
1. istio-ingressgateway service to access the microservices deployed and exposed in the Kubernetes cluster.
    - In these, examples we will be using HTTP and HTTPS protocols to access the cluster.

    `http://<external ip or minikube ip>:<port 80 or mapped node port>` 
    `https://<external ip or minikube ip>:<port 443 or mapped node port>`

2. kiali service: to visualize the service mesh
    
    `http://<host IP>:32000`

### Installing addons.
- Addons are not mandatory, but supportive artifacts for the service mesh. You can find manifest files for each addon using the link below.
    - [Istio addons](https://istio.io/v1.11/docs/ops/integrations/) 
- The artifacts for the addons are located inside *istio-installation/addons* directory.
    - Use the ***kubectl apply -f \<add on file>*** to deploy the addons on Kubernetes cluser.


