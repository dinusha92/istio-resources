#! /bin/sh

#cCeate the istio-system namespace
kubectl apply -f ./istio/1-namespace.yaml
sleep 0.5

#Applying the CRDs on the cluster
kubectl apply -f ./istio/2-istio-crds.yaml
sleep 1

#Deploying the Istio artifacts
kubectl apply -f ./istio/3-istio-install.yaml
sleep 2

#Installing Prometheus
kubectl apply -f ./istio/4-prometheus.yaml
sleep 0.5

#Installing Kiali
kubectl apply -f ./istio/5-kiali.yaml
sleep 0.5

