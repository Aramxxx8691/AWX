# 📘 AWX + Portainer + Grafana Deployment Guide
## 🧩 Summary
This guide shows how to deploy AWX using Minikube, then integrate it with Portainer for Docker management and Grafana for system monitoring.

For each new client, the process is:
- Add the client to AWX
- Launch the provisioning job
- Connect client to Portainer
- Add client metrics to Grafana (Prometheus)

## 🧰 Prerequisites
- Ubuntu 22.04+
Installed:
- Docker
- Minikube
- kubectl

### 🚀 Step 1: Deploy AWX via Minikube
1. Install Tools
```
sudo apt install docker.io kubectl minikube -y
```
2. Start Minikube
```
minikube start --driver=docker
```
3. Deploy AWX Operator
```
kubectl apply -f https://github.com/ansible/awx-operator/releases/download/0.21.0/release-0.21.0.yaml
```
4. Deploy AWX Instance
Create awx-deploy.yaml:
```
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: NodePort
  ingress_type: none
  admin_user: admin
  admin_password: admin
```
Apply it:
```
kubectl apply -f awx-deploy.yaml
```
5. Get AWX URL
```
minikube service awx-demo --url
```
6. Login
```
Username: admin
Password: admin
```

### 🐳 Step 2: Deploy Portainer Grafana + Prometheus (Optional)
monitoring.yml
```
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - 9000:9000
    volumes:
      - portainer_data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      placement:
        constraints: [node.role == manager]

  grafana:
    image: grafana/grafana:latest
    ports:
      - 3000:3000
    volumes:
      - grafana-storage:/var/lib/grafana
    deploy:
      placement:
        constraints: [node.role == manager]

volumes:
  portainer_data:
  grafana-storage:
```

#### Start:
```
docker-compose -f monitoring.yaml up -d
```

#### Access:
- portainer ➡️ http://localhost:9000
- grafana ➡️ http://localhost:3000

docker-compose.yml
```
version: '3'

services:
#  awx:
#    image: ansible/awx:17.1.0
#    ports:
#      - "8052:8052"
#    volumes:
#      - ./awx_env/environment.sh:/etc/tower/conf.d/environment.sh
#    depends_on:
#      - awx_postgres
#    restart: always

  awx_postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: awx
      POSTGRES_PASSWORD: awxpass
      POSTGRES_DB: awx
    volumes:
      - pg_awx_data:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4:latest
    ports:
      - "8080:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - awx_postgres

volumes:
  pg_awx_data:
  pgadmin_data:
```

#### Start:
```
docker-compose up -d
```

### 👥 Step 4: Add a New Client

1. In AWX
- Create a new Inventory or add a host
- Create or duplicate a Template
- Add appropriate Credentials

2. Launch AWX Job
- Run the template to install required services (e.g., Docker, Prometheus Node Exporter)

3. Connect to Portainer
Since you’re using Docker Swarm:
- Go to Portainer > Environments > Add Environment
- Use remote Docker API or Swarm Agent to connect the new client’s Docker service to Portainer.

4. Add Metrics to Grafana
In prometheus.yml:
```
scrape_configs:
  - job_name: 'clients'
    static_configs:
      - targets: ['<CLIENT_IP>:9100']
```
Restart Prometheus and add a new dashboard in Grafana (Node Exporter or custom).


📎 Include Screenshots
