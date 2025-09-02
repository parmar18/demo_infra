--------------------------------------------------
Infra Demo: Flask App on GCP
--------------------------------------------------

This project deploys a containerized Flask app to Google Cloud Platform (GCP) 
using Terraform. It demonstrates Infrastructure-as-Code, containerization, 
and global load balancing.


--------------------------------------------------
Architecture
--------------------------------------------------

User --> Global HTTP Load Balancer --> Backend Service --> MIG --> VM (Debian + Docker) --> Flask App

Components:
- VPC + Firewall: Isolated network, allows HTTP/HTTPS/health/SSH
- Artifact Registry: Stores Docker image (us-central1-docker.pkg.dev/...:v3)
- MIG (Managed Instance Group): Auto-manages VM lifecycle with startup script
- Instance Template: Installs Docker, pulls the image, runs the Flask container
- Load Balancer: Global entrypoint, health checks /health, routes traffic


--------------------------------------------------
App Endpoints
--------------------------------------------------

/health   -> returns OK (for LB checks)
/         -> returns welcome message
/search?q= -> returns definition (from a small knowledge base)

Example:

curl http://<LB_IP>/search?q=docker

Response:
{"docker": "Platform for containerizing applications with all dependencies."}


--------------------------------------------------
Deployment Technique
--------------------------------------------------

1. Build and push image:

docker buildx build --platform linux/amd64 \
  -t us-central1-docker.pkg.dev/<PROJECT>/<REPO>/search-app:v3 \
  --push .

2. Provision infra with Terraform:

terraform init
terraform apply -auto-approve

3. Get Load Balancer IP:

terraform output -raw lb_ip


--------------------------------------------------
Best Practices Applied
--------------------------------------------------

- Modular Terraform (vpc, firewall, compute, loadbalancer)
- MIG update_policy for rolling updates
- Health check aligned with /health endpoint
- Enabled HTTPS with domain + managed certs
- Startup script logs to /var/log/search-app.log
- .gitignore excludes secrets and state files

--------------------------------------------------
Best Practices To-Be Applied
--------------------------------------------------

- Setting up of Development and Staging Enviornments
- Improve scaling & resiliency depending on the requirements
- Add observability & alerts
- Store secrets in GCP Secret Manager instead of code
- Add automated tests for startup scripts and health checks


--------------------------------------------------
Issues I ran into
--------------------------------------------------

- Docker Image Architecture Mismatch
  Built the image on Mac (ARM) while GCP VMs required AMD64. Fixed by rebuilding with --platform linux/amd64.

- Startup Script Errors in main.tf
  Initial VM startup script failed to correctly pull and run the container. Needed retries and better logging to debug.

- Load Balancer Health Check Failures
  Health check kept failing until the containerized app exposed the correct /health endpoint on the expected port (8080).

- Image Pull Issues
  Even when health checks were configured, the container sometimes wasn’t pulled/run properly from Artifact Registry. Ensured correct image tags and permissions.

- SSL Certificate & DNS Integration
  Managed SSL certificate initially showed FAILED_NOT_VISIBLE due to DNS pointing at the wrong/ephemeral IP. Fixed by reserving a static global IP and updating DNS records.

