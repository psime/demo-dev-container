#!/bin/bash
set -e

echo "⚙️  Configuring kubectl for Minikube..."
minikube update-context

echo "⏳ Waiting for Minikube to be ready..."
kubectl wait --for=condition=ready node --all --timeout=120s

echo "🚇 Starting Minikube tunnel..."
nohup minikube tunnel >/tmp/minikube-tunnel.log 2>&1 &
sleep 3

echo "🧹 Cleaning up old helm release..."
helm uninstall myapp 2>/dev/null || true

echo "🚀 Deploying app..."
make start-helm

echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=myapp --timeout=60s

echo "⏳ Waiting for LoadBalancer IP..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/myapp --timeout=60s

echo "✅ Ready! Service available at http://localhost:9000"
echo "💡 Run 'k9s' to open Kubernetes dashboard"
