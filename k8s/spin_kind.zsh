# Script to spin up k8s cluster using kind and create an nginx pod
# Assumptions kind is already installed
# This script is created as a workaround since my machine has problem in hibernate mode

echo "Deleting existing cluster pai and creating new one"
kind delete cluster --name pai
kind create cluster --name pai

sleep 10

echo "Creating apps namespace and spinning up a nginx pod"
kubectl create namespace apps
sleep 10
kubectl run --generator=run-pod/v1 nginx --image nginx:1.17.9 -n apps
sleep 10

echo "Get pods in apps namespace"
kubectl get pods -n apps
