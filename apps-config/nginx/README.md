# Nginx Hello World

Simple nginx deployment for testing the Kubernetes cluster.

## What's Deployed

- **Deployment**: 2 nginx replicas with resource limits and health checks
- **Service**: NodePort service exposing nginx on port 30080

## Deploy

```bash
# Apply all manifests
kubectl apply -f apps-config/nginx/

# Or apply individually
kubectl apply -f apps-config/nginx/deployment.yaml
kubectl apply -f apps-config/nginx/service.yaml
```

## Verify Deployment

```bash
# Check pods are running
kubectl get pods -l app=nginx

# Check service
kubectl get svc nginx

# Check deployment
kubectl get deployment nginx
```

## Access Nginx

The service is exposed as NodePort on port 30080. Access it using any node IP:

```bash
# Using your control plane node IP
curl http://192.168.0.15:30080

# Or open in browser
# http://192.168.0.15:30080
```

Replace `192.168.0.15` with your actual node IP address.

## Cleanup

```bash
kubectl delete -f apps-config/nginx/
```
