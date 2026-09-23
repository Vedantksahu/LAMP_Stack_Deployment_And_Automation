# Task 2 — Kubernetes Deployment

## 1. Get a local multi-node cluster (pick one)

**kind** (fastest, runs as Docker containers — good fit for WSL):
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --name lamp --config kind-config.yaml
```
Either way, confirm: `kubectl get nodes` shows 2+ nodes as Ready.

## 2. Push your Task-1 image somewhere the cluster can pull it
```bash
docker build -t <dockerhub-user>/lamp-web:latest ../task1-docker
docker push <dockerhub-user>/lamp-web:latest
```
Then edit `frontend-deployment.yaml` and replace `<dockerhub-user>/lamp-web:latest`
with your actual image. (If using kind, you can instead `kind load docker-image
<dockerhub-user>/lamp-web:latest --name lamp` and skip the registry push.)

## 3. Apply everything (order matters: config/secrets/storage before workloads)
```bash
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f pv-pvc.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f hpa.yaml
```

## 4. Verify
```bash
kubectl get pods -w
kubectl get svc
kubectl get hpa
```
`metrics-server` must be running for HPA to report real numbers — on kind/minikube:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# on kind, metrics-server needs --kubelet-insecure-tls; patch it:
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

## 5. Access the app
```bash
# kind
kubectl port-forward svc/frontend-service 8080:80
# then open http://localhost:8080

# minikube
minikube service frontend-service --url
```

## 6. Prove the rolling update is zero-downtime
```bash
# in one terminal, hammer the endpoint
while true; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080; sleep 0.5; done

# in another terminal, trigger a rolling update
kubectl set image deployment/frontend frontend=<dockerhub-user>/lamp-web:v2
kubectl rollout status deployment/frontend
```
You should see all `200`s throughout — that's `maxUnavailable: 0` doing its job.

## Design notes / assumptions
- MySQL runs as a single-replica StatefulSet for simplicity; real HA would need
  MySQL Group Replication or an operator (e.g. Percona XtraDB Cluster operator) —
  a StatefulSet alone does not replicate data across replicas.
- `mysql-service` is headless (`clusterIP: None`) and has no NodePort/LoadBalancer,
  so it's unreachable from outside the cluster — only pods inside can resolve it.
- Secrets here are base64 only, not sealed/encrypted — acceptable for local
  practice, called out explicitly as a gap for production.
- `frontend-service` uses NodePort for local testing; swap `type: LoadBalancer`
  when deploying to a cloud provider (EKS/GKE/AKS) or with MetalLB on-prem.
