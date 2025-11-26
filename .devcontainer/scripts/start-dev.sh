#!/bin/bash
set -e

echo "🧹 Cleaning up old helm release..."
helm uninstall myapp 2>/dev/null || true

echo "🚀 Deploying app..."
make start-helm

echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=myapp --timeout=60s

echo "🔌 Starting port forwards..."
kubectl port-forward service/myapp 8080:9000 8090:9000 --address 0.0.0.0 > /tmp/port-forward.log 2>&1 &

echo "✅ Ready! Ports 8080 and 8090 forwarded."
echo "💡 Run 'k9s' to open Kubernetes dashboard"
