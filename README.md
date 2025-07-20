

---

### ✅ `README.md` – VideoTube: Cloud-Native YouTube Clone 🚀

```markdown
# 🎥 VideoTube – YouTube-Style Video Platform (Cloud-Native)

A scalable, production-style architecture to simulate a YouTube-like video streaming app using:

- 🛠 **Terraform** for infrastructure as code  
- 🚀 **Docker** for app containerization  
- ☸️ **Amazon EKS (Kubernetes)** for orchestration  
- 🧪 **Jenkins** for CI/CD  
- 📦 **Helm** for Kubernetes deployments  
- 🧠 **Prometheus + Grafana** for monitoring  
- 🗂 **S3 + CloudFront** for video delivery  
- 🧬 **RDS** for metadata  
- 🧬 **Lambda + FFmpeg** for transcoding  
- 🔐 **Secrets Manager, IAM, WAF** for security  
- ☁️ **Deployed using GCP VM** as DevOps Workstation

---

## 📁 Project Structure

```

.
├── terraform/
│   ├── vpc.tf
│   ├── eks-cluster.tf
│   ├── iam.tf
│   ├── nodegroup.tf
│   ├── s3.tf
│   ├── rds.tf
│   ├── lambda.tf
│   ├── outputs.tf
│   └── main.tf
├── lambda/
│   └── transcoder\_lambda.py
├── backend/
│   ├── Dockerfile
│   ├── app.js
│   └── ...
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   └── styles.css
├── monitoring/
│   ├── prometheus.yaml
│   └── grafana/
│       └── dashboards/
│           └── youtube\_dashboard.json
├── jenkins/
│   └── Jenkinsfile
├── helm/
│   └── video-app/
│       ├── templates/
│       └── values.yaml
└── README.md

````

---

## 🚦 PHASE-BY-PHASE SETUP

---

## ✅ Phase 1: GCP DevOps Workstation Setup

Provision GCP VM:
- Ubuntu 22.04 LTS
- 50 GB disk, 2 vCPU, 4 GB RAM (e2-medium)

Install tools:
```bash
sudo apt update && sudo apt install -y unzip curl wget git
# Install Docker
sudo apt install docker.io -y
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/hashicorp.gpg
echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# eksctl
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz
sudo mv eksctl /usr/local/bin

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Jenkins
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update && sudo apt install jenkins -y
````

Configure AWS:

```bash
aws configure
# Use Access Key, Secret, us-east-1, json
```

---

## ✅ Phase 2: Create EKS Cluster (Terraform)

Directory: `terraform/`

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

> This creates:
>
> * VPC
> * Subnets
> * Security Groups
> * EKS Cluster
> * IAM roles
> * Managed Node Group with Bottlerocket AMI

Update kubeconfig:

```bash
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
kubectl get nodes
```

---

## ✅ Phase 3: Dockerize the Application

**Backend:**

* Node.js-based service connecting to RDS and S3

**Frontend:**

* React (or HTML/CSS if lightweight)

Build images:

```bash
docker build -t videotube-backend ./backend/
docker build -t videotube-frontend ./frontend/
```

Push to AWS ECR :

```bash
# Docker Hub
docker tag videotube-backend <username>/videotube-backend
docker push <username>/videotube-backend
```

---

## ✅ Phase 4: Deploy with Helm + Jenkins

Write Helm chart: `helm/video-app/`

Deploy with Helm:

```bash
helm install video-app ./helm/video-app --namespace video-app --create-namespace
```

Set up Jenkins pipeline:

* Use `Jenkinsfile`
* Trigger builds on commits
* Auto deploy via `helm upgrade`

---

## ✅ Phase 5: Integrate RDS + S3 + CloudFront

* `terraform/rds.tf`: PostgreSQL DB
* `terraform/s3.tf`: S3 bucket
* `terraform/cloudfront.tf`: CDN for video delivery
* Use Secrets Manager to store DB creds

---

## ✅ Phase 6: Lambda + FFmpeg (Transcoding)

Trigger Lambda on new video upload to S3:

* Convert formats (mp4, webm)
* Store output in another S3 path
* Update metadata in RDS

Defined in `terraform/lambda.tf`
Code in `lambda/transcoder_lambda.py`

---

## ✅ Phase 7: Monitoring & Observability

**Prometheus + Grafana** deployed using Helm:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

This project includes monitoring with Prometheus and Grafana deployed using Helm. Prometheus is installed via the `kube-prometheus-stack` chart in the `monitoring` namespace with temporary in-memory storage (`helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace`). The backend exposes metrics at `/metrics` using `prom-client`, and a `ServiceMonitor` is applied to allow Prometheus to scrape them (`kubectl apply -f servicemonitor.yaml`). Grafana can be accessed via `kubectl port-forward svc/monitoring-grafana -n monitoring 3001:80` and comes pre-configured with Prometheus as a data source.


Add Grafana dashboards:

* Located in `monitoring/grafana/dashboards/youtube_dashboard.json`

CloudWatch alarms can also be configured (optional).

---

## 🛡 Security Enhancements

* TLS for Ingress (via cert-manager)
* WAF (optional)
* IAM Roles for EKS, Lambda, S3 access
* S3 Lifecycle rules

---

## 📦 Deployment Pipeline Summary

1. Developer commits → Jenkins triggers
2. Jenkins builds Docker images
3. Jenkins pushes to ECR or Docker Hub
4. Helm upgrades Kubernetes workloads
5. Monitoring alerts via Prometheus + Grafana

---

## 👨‍💻 Author

**Ankit Gupta**
Cloud/DevOps Engineer | AWS | Kubernetes | Jenkins | Terraform
📍 Toronto, Canada
📧 [ankitgup.05@gmail.com](mailto:ankitgup.05@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/ankit--gupta)
🐙 [GitHub](https://github.com/Rajeshgupta123456789)

---

```


```
