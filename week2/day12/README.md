# Day 12 — File Content, RDS Skeleton, Rolling Update, Backup & Multi-branch Pipelines

This directory contains the implementations for **Day 12 — Week 2**.

---

## 1. 🔹 Ansible — Ensure File With Content (`create-config.yml`)
- Writes multi-line text to `/etc/pathnex.conf` using the `copy` module's `content` parameter.

```yaml
---
- name: Create config file for Pathnex
  hosts: all
  become: yes

  tasks:
    - name: Write content to file
      copy:
        dest: /etc/pathnex.conf
        content: |
          Welcome to Pathnex DevOps Training
          Today is Day 12
```

---

## 2. 🔹 Terraform — RDS Skeleton (`main.tf`)
- Declares an Amazon RDS MySQL instance skeleton (`PathnexRDS`) with 20GB storage, `db.t3.micro` class, and `skip_final_snapshot = true`.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "PathnexRDS" {
  allocated_storage   = 20
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  db_name             = "pathnexdb"
  username            = "admin"
  password            = "password123"
  skip_final_snapshot = true

  tags = {
    Name = "Pathnex-RDS"
  }
}
```

---

## 3. 🔹 Kubernetes — Rolling Update Strategy (`rolling-update.yaml`)
- Configures an Nginx Deployment with 3 replicas.
- Applies a `RollingUpdate` strategy allowing `maxSurge: 1` and `maxUnavailable: 1` for zero-downtime updates.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pathnex-rolling
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: roll
  template:
    metadata:
      labels:
        app: roll
    spec:
      containers:
        - name: web
          image: nginx
```

---

## 4. 🔹 Shell Script — Backup Directory (`backup.sh`)
- Creates a timestamped gzip tar archive of `/var/log` at `/backup/pathnex-$(date +%F).tar.gz`.

```bash
#!/bin/bash

SOURCE="/var/log"
DEST="/backup/pathnex-$(date +%F).tar.gz"

tar -czf $DEST $SOURCE
echo "Backup created at: $DEST"
```

---

## 5. 🔹 Jenkins Pipeline — Multi-branch (`Jenkinsfile`)
- Uses `checkout scm` to dynamically check out the active Git branch being evaluated by the multibranch pipeline job.

```groovy
pipeline {
    agent any
    environment {
        INSTITUTE_NAME = "Pathnex"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
    }
}
```

---

## 6. 🔹 GitLab CI — Branch Specific Jobs (`.gitlab-ci.yml`)
- Defines dedicated build jobs (`build-main` and `build-dev`) restricted to target branches via `only: - main` and `only: - dev`.
