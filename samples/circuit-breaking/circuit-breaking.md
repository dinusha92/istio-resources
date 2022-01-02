 ## Circuit Breaking With Istio Service Mesh
 
 *Circuit Breaking* is a microservice design concept on maintaining a stable deployment in an event of a failures of a microservice.
 Without the circuit breaking, an error in a particular microservice can make the whole system unstable.
 By applying circuit breaking, the deployment is configured to identify how to behave on an errorneous situation.


 # Scenario

 Hello microservice would return "hello!" when calling the ***/hello*** resource.
 We are deploying two deployments with one microservice returning "hello!" when calling the ***/hello*** resource and the other microservice returning a time out error when calling the ***/hello*** response.

Let's deploy the application.

1. Enable istio for the default namespace.
```
 kubectl apply -f 1-label-default-namespace.yaml
```
2. Deploy the mock backends and application.
```
 kubectl apply -f 2-hello-backend-cm.yaml 

 kubectl apply -f 3-timeout-backend-cm.yaml

 kubectl apply -f 4-application-no-istio.yaml
```
3. Deploy the gateway configurations and routing configurations.
```
 kubectl apply -f 5-gateway.yaml
```

#### Accessing Services

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


Invoke the service

`while true; do curl http://<external ip or minikube ip>:<port 80 or mapped node port>/hello;echo; sleep 0.5 ; done`

```
hello!
hello!
upstream request timeout
upstream request timeout
hello!
upstream request timeout
hello!
upstream request timeout
hello!
upstream request timeout
hello!
hello!
upstream request timeout
upstream request timeout
hello!
hello!
upstream request timeout
upstream request timeout
hello!
upstream request timeout
hello!
upstream request timeout
hello!
hello!
upstream request timeout
upstream request timeout
hello!
hello!
upstream request timeout
upstream request timeout

```

You would get response from both the backends without circuit breaking. In a typical deployment, this could propegate errors in the whole deployment resulting a deployment wide issues.

But with circuit breaking enabled, we instruct the service mesh(to envoy proxies) to not forward traffic to a pod if it's taking too much time to response. 

```
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: circuit-breaker-for-the-entire-default-namespace
spec:
  host: "mock-service.default.svc.cluster.local"   # Kubernetes service name the rule to be applied on
  trafficPolicy:
    outlierDetection: # Enabling CIRCUIT BREAKING
      maxEjectionPercent: 100
      consecutive5xxErrors: 3  #How many errors should be occurred to trigger circuit breaking
      interval: 10s #Time interval of the errors to be occurred.
      baseEjectionTime: 10s
 
```

In our example, if there are 3 5XX errors occurred during 10 seconds internal, the circuit will be tripped resulting not forwarding the traffic to the 5xx giving backend for 30 seconds. Then after 30 seconds, it will again forward the traffic and check if it works.

4. Enable Circuit Breaking

Enable the circut breaking.
```
 kubectl apply -f 6-circuit-breaking.yaml
```

Verified the circuit breaking.


`while true; do curl http://<external ip or minikube ip>:<port 80 or mapped node port>/hello;echo; sleep 0.5 ; done`

```
hello!                    ──┐
upstream request timeout    └┐
hello!                       │      Before Circuit is tripped.
upstream request timeout     ├───
hello!                       │
upstream request timeout   ┌─┘
hello!         ─┐         ─┘
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          ├──    Circuit is tripped and forwarding traffic to healthy pods
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!          │
hello!         ─┘
upstream request timeout ─┐
upstream request timeout  │    After 30 seconds,traffic is temporarily forwarding
hello!                    ├─
hello!                    │     to the other pods untill the circuit is tripped.
upstream request timeout  │
hello!                   ─┘
hello!

```