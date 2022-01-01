 ## Circuit Breaking With Istio Service Mesh
 
 *Circuit Breaking* is a microservice design concept on maintaining a stable deployment in an event of a failures of a microservice.
 Without the circuit breaking, an error in a particular microservice can make the whole system unstable.


Enable istio for the default namespace.
```
 kubectl apply -f 1-label-default-namespace.yaml
```
Deploy the mock backends.
```
 kubectl apply -f 2-hello-backend-cm.yaml 

 kubectl apply -f 3-timeout-backend-cm.yaml

 kubectl apply -f 4-application-no-istio.yaml
```
Deploy the gateway configurations and routing configurations.
```
 kubectl apply -f 5-gateway.yaml
```

Enable the circut breaking.
```
 kubectl apply -f 6-circuit-breaking.yaml
```

minikube ip


kubectl get svc -n istio-system 

```
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.111.128.21    <none>        80/TCP,443/TCP                                                               13m
istio-ingressgateway   LoadBalancer   10.110.87.74     <pending>     15021:31615/TCP,80:30563/TCP,443:30339/TCP,31400:32074/TCP,15443:31778/TCP   13m
istiod                 ClusterIP      10.105.154.204   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        13m

```


while true; do curl http://192.168.99.134:30563/hello;echo; sleep 0.5 ; done