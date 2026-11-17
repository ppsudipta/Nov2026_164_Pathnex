# Day 07 — SPEED TYPING & Parameterized Builds

This directory contains the implementations for **Day 07 — SPEED TYPING & Parameterized Builds**.

---

## 1. 🔹 Ansible (`install-nginx.yml`)
Rewritten from scratch:
- Targets `hosts: all` with `become: yes`.
- Installs the Nginx package using the `package` module for distro portability.
- Starts and enables the `nginx` service.
- Includes `inventory.ini` for local or remote execution.

```yaml
---
- name: Install and start nginx
  hosts: all
  become: yes
  tasks:
    - name: Install Nginx
      package:
        name: nginx
        state: present

    - name: Start and enable Nginx service
      service:
        name: nginx
        state: started
        enabled: yes
```

---

## 2. 🔹 Terraform (`main.tf`)
Rewritten from scratch:
- Configures AWS provider in `ap-southeast-2`.
- Queries the latest Amazon Linux 2023 AMI via `aws_ami` data source.
- Launches an EC2 instance (`t3.micro`) tagged as `Pathnex-EC2`.

```hcl
provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "PathnexEC2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name        = "Pathnex-EC2"
    Environment = "Training"
    Owner       = "Pathnex"
  }
}
```

---

## 3. 🔹 Kubernetes (`deployment.yaml`)
Rewritten from scratch:
- Deploys an Nginx application with `replicas: 2`.
- Uses label selector matching `app: pathnex-app`.
- Exposes container port `80`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pathnex-deployment
  labels:
    app: pathnex-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pathnex-app
  template:
    metadata:
      labels:
        app: pathnex-app
    spec:
      containers:
        - name: app
          image: nginx
          ports:
            - containerPort: 80
```

---

## 4. 🔹 Shell Script (`date_uptime.sh` / `system-info.sh`)
Rewritten from scratch:
- Prints the current system date and time.
- Prints system uptime.

```bash
#!/bin/bash
echo "=== System Information ==="
echo "Current Date & Time: $(date)"
echo "System Uptime: $(uptime)"
```

---

## 5. 🔹 Jenkins Pipeline — Parameterized (`Jenkinsfile`)
- Defines build parameter `ENVIRONMENT` with a default of `dev`.
- Defines pipeline environment variable `INSTITUTE_NAME = "Pathnex"`.
- Checks out source code and executes a parameterized deploy stage displaying:
  `Deploying to $ENVIRONMENT by $INSTITUTE_NAME`

---

## 6. 🔹 GitLab CI — Parameterized via Variables (`.gitlab-ci.yml`)
- Declares global variables `INSTITUTE_NAME: "Pathnex"` and `ENVIRONMENT: "dev"`.
- Executes job `deploy` on Alpine image outputting:
  `Deploying to $ENVIRONMENT by $INSTITUTE_NAME`
