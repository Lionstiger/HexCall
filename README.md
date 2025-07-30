# Hexcall

TODO

# Dev

## Kubernetes

HTTPS Setup (Needed for WebRTC)

```bash
minikube start
mkcert hexcall.example
kubectl -n kube-system create secret tls mkcert --key hexcall.example-key.pem --cert hexcall.example.pem
minikube addons configure ingress
# Enter kube-system/mkcert
minikube addons enable ingress
```

Install Stunner

```bash
helm repo add stunner https://l7mp.io/stunner
helm repo update
helm install stunner stunner/stunner --create-namespace --namespace=stunner-system
```

Use Manifests

```bash
minikube dashboard --url # Nice to have, not required

kubectl apply -f ./k8s/db.yaml
kubectl apply -f ./k8s/service_account.yaml
kubectl apply -f ./k8s/stunner.yaml

# Update ICE_URL to the ip of the udp_gateway(for minikube)
kubectl get svc -n stunner
kubectl apply -f ./k8s/hexcall.yaml
```

Finally add local dns bypass for the selfsigned cert to your /etc/hosts

```bash
echo "$(minikube ip) hexcall.example"
# Add to /etc/hosts
sudo nano /etc/hosts
```

You should be able to access the application on https://hexcall.example

## Local Dev

Set SECRET_KEY_BASE first:

```bash
export SECRET_KEY_BASE=$(mix phx.gen.secret)
```

Start a local postgres instance:

```bash
docker run --name postgres \
--detach \
--publish 5432:5432 \
-e POSTGRES_HOST_AUTH_METHOD=trust \
--mount type=tmpfs,destination=/tmp/postgresql/data \
postgres
```

Run server with

```bash
mix phx.server
```

or inside IEx with

```bash
iex -S mix phx.server
```

## Docker

Build with:

```bash
docker build .
```

Run (adjust env as needed):

```bash
docker run --rm \
--network="host" \
-e PHX_HOST=localhost \
-e DATABASE_URL="ecto://postgres:postgres@localhost/hexcall_dev" \
-e SECRET_KEY_BASE=TiBFjhsHAWALNyNKhuVd7fMJ+ARH13hQzGRv3+wWsq/XCICB2YhmvajzJjAaqDRo \
hexcall
```

## Docker Compose

Adjust `.env`, then:

```bash
docker compose up
```
