Infra Demo: Flask App on GCP

This project deploys a containerized Flask app to Google Cloud Platform (GCP) using Terraform.
It demonstrates:

Infrastructure-as-Code (IaC)

Containerization (Docker)

Global load balancing

🏗️ Architecture
User --> Global HTTP Load Balancer --> Backend Service --> MIG --> VM (Debian + Docker) --> Flask App


VPC + Firewall: Isolated network, allows HTTP/HTTPS/health/SSH.

Artifact Registry: Stores Docker image (us-central1-docker.pkg.dev/...:v3).

MIG (Managed Instance Group): Auto-manages VM lifecycle with startup script.

Instance Template: Installs Docker, pulls the image, runs the Flask container.

Load Balancer: Global entrypoint, health checks /health, routes traffic.

🌐 App Endpoints

/health → returns OK (for LB checks)

/ → returns welcome message

/search?q= → returns definition (from a small knowledge base)

Example:

curl http://<LB_IP>/search?q=docker


Response:

{
  "docker": "Platform for containerizing applications with all dependencies."
}

🚀 Deployment Technique
1. Build and push image
docker buildx build --platform linux/amd64 \
  -t us-central1-docker.pkg.dev/<PROJECT>/<REPO>/search-app:v3 \
  --push .

2. Provision infra with Terraform
terraform init
terraform apply -auto-approve

3. Get Load Balancer IP
terraform output -raw lb_ip

✅ Best Practices Applied

Modular Terraform (vpc, firewall, compute, loadbalancer)

MIG update_policy for rolling updates

Health check aligned with /health endpoint

Startup script logs to /var/log/search-app.log

.gitignore excludes secrets and state files

📚 Lessons Learned

Always build multi-arch images when developing on ARM Macs

Match LB health checks with app endpoints

Use update_policy in MIGs for smooth rollouts

Log startup scripts for easier debugging
