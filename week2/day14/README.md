# Day 14 — MINI PROJECT & Scheduled Pipelines

This directory contains the complete end-to-end implementation for **Day 14 — MINI PROJECT**.

---

## 1️⃣ Terraform — Full AWS Infrastructure Provisioning (`main.tf`)
Provisions complete production-grade cloud infrastructure in AWS (`us-east-1`):
- **VPC**: `PathnexVPC` (`10.14.0.0/16`) with DNS support and hostnames enabled.
- **Internet Gateway**: `PathnexIGW` attached to the VPC.
- **Subnet**: Public Subnet `PathnexSubnet` (`10.14.1.0/24`) in `us-east-1a` with auto public IP mapping.
- **Route Table**: `PathnexRT` with default route `0.0.0.0/0` routed to the Internet Gateway.
- **Association**: `PathnexRTA` connecting the subnet to the route table.
- **Security Group**: `PathnexSG` with inbound rules for HTTP (port 80) and SSH (port 22).
- **EC2 Instance**: `PathnexEC2` provisioned with instance type `c5.xlarge` using dynamic Amazon Linux 2023 AMI lookup.
- **Outputs**: Exports `instance_public_ip`.

---

## 2️⃣ Ansible — Install Nginx & Deploy HTML File (`deploy-nginx.yml`)
- Playbook installing Nginx across target hosts.
- Deploys custom HTML dashboard (`index.html`) to `/usr/share/nginx/html/index.html`.
- Uses handlers to notify and reload Nginx upon configuration updates.
- Ensures service is started and enabled.

---

## 3️⃣ Kubernetes — Deployment + Service (`k8s-deployment-service.yaml`)
- **Deployment**: `pathnex-deployment` running 2 replicas of Nginx (`image: nginx:latest`) with container port `80`.
- **Service**: `pathnex-service` exposing the deployment via `NodePort` on port `80` (NodePort: `30080`).

---

## 4️⃣ Shell — System Metrics Report (`system_metrics.sh`)
- Formatted script checking:
  1. CPU load / usage (`top` / `uptime`)
  2. Memory utilization (`free -h`)
  3. Disk space status (`df -h /`)

---

## 5️⃣ Scheduled Pipelines
### 🔹 Jenkins Pipeline (`Jenkinsfile`)
- Configured with `triggers { cron('H 2 * * *') }` to automatically execute scheduled builds daily at 2:00 AM.
- Executes checkout and packaging with `mvn clean package`.

### 🔹 GitLab CI Scheduled Pipeline (`.gitlab-ci.yml`)
- Configured to execute Maven packaging jobs triggered via GitLab CI Scheduled Pipeline schedules.

