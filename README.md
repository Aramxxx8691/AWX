# 🚀 Step-by-Step: Deploy AWX on Docker Desktop Kubernetes
## 1. ✅ Prerequisites (you already have):
Docker Desktop with Kubernetes enabled (✔️)

kubectl installed and working (✔️)

Test with:
```
kubectl get nodes
```
Should return one node: docker-desktop.

## 2. 🛠 Create the awx namespace

```
kubectl create namespace awx
```

## 3. ⬇️ Clone the AWX Operator repo
```
git clone https://github.com/ansible/awx-operator.git
cd awx-operator
git checkout 2.19.0
```

## 4. 🚀 Deploy the AWX Operator
```
make deploy NAMESPACE=awx
```
⚠️ This uses kustomize under the hood — it deploys Custom Resource Definitions (CRDs) and the AWX controller.

## 5. 📦 Create your AWX deployment YAML
Create a file called `awx-deploy.yaml` in the root of the project:
```
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
  namespace: awx
spec:
  service_type: nodeport
  ingress_type: none
  replicas: 1
  admin_user: admin
  admin_password_secret: awx-admin-password
```

## 6. 🔐 Create the admin password secret
```
kubectl create secret generic awx-admin-password --from-literal=password=admin -n awx
```

## 7. 🚀 Apply your AWX deployment
```
kubectl apply -f awx-deploy.yaml
```

## 8. 🌐 Access AWX Web Interface
Get the NodePort:
```
kubectl get svc -n awx
```
Look for awx-demo-service and find the NODEPORT, then open in browser:
```
http://localhost:<NODEPORT>
```
Login:
- Username: admin
- Password: admin

## 9. ⚙️ Other tools
docker-compose.yml
```
version: "3.8"

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    ports:
      - "3000:3000"
    depends_on:
      - postgres
    networks:
      - awx-network

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - awx-network

  postgres:
    image: postgres:15
    container_name: postgres
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: awx
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - awx-network

  pgadmin:
    image: dpage/pgadmin4
    container_name: pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - awx-network

volumes:
  portainer_data:
  postgres_data:

networks:
  awx-network:
    driver: bridge
```

## 10. 🧭 Access After Running
- AWX: http://localhost:<NODEPORT>
- Grafana: http://localhost:3000
- Portainer: http://localhost:9000
- pgAdmin: http://localhost:5050