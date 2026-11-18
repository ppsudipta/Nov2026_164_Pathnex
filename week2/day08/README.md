# Day 08 — Variables, VPC, Probes, Loops & Conditional Stages

This directory contains the implementations for **Day 08 — Week 2**.

---

## 1. 🔹 Ansible — Install Packages Using Variables (`install-packages.yml`)
- Declares a list variable `pathnex_packages` containing `tree`, `unzip`, and `vim`.
- Passes the variable to the `yum` module to install all packages in a single batch.

```yaml
---
- name: Install packages for Pathnex using variables
  hosts: all
  become: yes

  vars:
    pathnex_packages:
      - tree
      - unzip
      - vim

  tasks:
    - name: Install required packages
      yum:
        name: "{{ pathnex_packages }}"
        state: present
```

---

## 2. 🔹 Terraform — Create VPC + Subnet (`main.tf`)
- Creates an AWS VPC (`Pathnex-VPC`) with CIDR block `10.10.0.0/16`.
- Creates a public Subnet (`Pathnex-Subnet`) with CIDR block `10.10.1.0/24` inside the VPC and enables `map_public_ip_on_launch = true`.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "PathnexVPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Pathnex-VPC"
  }
}

resource "aws_subnet" "PathnexSubnet" {
  vpc_id                  = aws_vpc.PathnexVPC.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pathnex-Subnet"
  }
}
```

---

## 3. 🔹 Kubernetes — Add Liveness & Readiness Probes (`pod-probes.yaml`)
- Configures an Nginx Pod `pathnex-probe-pod`.
- **Liveness Probe**: Tests HTTP GET on `/` at port `80` with `initialDelaySeconds: 5` to restart the container if unhealthy.
- **Readiness Probe**: Tests HTTP GET on `/` at port `80` with `initialDelaySeconds: 3` before routing network traffic to the container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pathnex-probe-pod
spec:
  containers:
    - name: web
      image: nginx
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 3
```

---

## 4. 🔹 Shell Script — Loop Through List (`loop.sh`)
- Iterates over the items `Pathnex`, `DevOps`, `Training` using a `for` loop and prints each item.

```bash
#!/bin/bash

for item in Pathnex DevOps Training; do
  echo "Item: $item"
done
```

---

## 5. 🔹 Jenkins Pipeline — Conditional Execution (`Jenkinsfile`)
- Stage **Build**: Uses `when { branch 'main' }` to compile only on the `main` branch.
- Stage **Deploy**: Uses `when { expression { params.ENVIRONMENT == 'dev' } }` to deploy only when the `ENVIRONMENT` parameter equals `dev`.

---

## 6. 🔹 GitLab CI — Conditional Jobs (`.gitlab-ci.yml`)
- Job **build**: Uses `only: - main` to trigger solely on commits to the `main` branch.
- Job **deploy**: Uses `only: variables: - $CI_ENVIRONMENT_NAME == "dev"` to conditionally execute based on environment variables.
