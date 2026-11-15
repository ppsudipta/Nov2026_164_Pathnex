# Day 04 — More Packages, Key Pair, Service

This directory contains solutions and explanations for all tasks in **Day 04** of the Pathnex DevOps Hands-On Practice (Level 1).

---

## 1. 🔹 Ansible — Install Multiple Packages (`install-packages.yml`)

### Overview
This playbook installs multiple packages (`git` and `wget`) on target hosts using the `yum` package manager module.

### Playbook Code:
```yaml
---
- name: Install packages for Pathnex
  hosts: all
  become: yes

  tasks:
    - name: Install tools
      yum:
        name:
          - git
          - wget
        state: present
```

### Notes & Testing:
- **Syntax check**:
  ```bash
  ansible-playbook --syntax-check -i inventory.ini install-packages.yml
  ```
- **Local / Cross-platform testing**:
  If running against an Ubuntu / Debian machine (where `apt` is used instead of `yum`), you can replace `yum:` with `package:` (Ansible's generic package manager module) or `apt:`.

---

## 2. 🔹 Terraform — EC2 with Key Pair (`main.tf`)

### Overview
Provisions an AWS Key Pair (`PathnexKey`) and launches an EC2 instance (`PathnexEC2`) configured with this key pair.

### Configuration Highlights:
- **`aws_key_pair`**: Defines the public key resource `PathnexKey`.
- **`aws_instance`**: Defines the EC2 instance `PathnexEC2` referencing `aws_key_pair.PathnexKey.key_name`.
- **AMI**: Uses dynamic lookup for the latest Amazon Linux 2023 AMI (in place of hardcoded placeholder `ami-0abcd1234abcd1234`).
- **Instance Type**: Specified as `c6i.8xlarge` as required by the exercise (can be switched to `t3.micro` for free tier/testing).

### Terraform Code:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

variable "public_key" {
  description = "Public key for SSH access to Pathnex EC2 instance"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8N5dH3vS7m2oRFn04DkdyPuGWezk6p8OozdpHCrU+QCDM3KVDGXjd3M/rL2srhSXfGxuUXB3bRoyI4GGagHQZZfNabBBY+uThtsnhzySRmHuaZod+I5CFs38htEHrZHlJ3H7dbcw4qDcRtUKyZVyZCqNiQj808FDW4JSsIerZ86V8V6Y2oLPoe+MNxNduD4d/pTtGWPKNOdLV4egTWepbgCF4g2MKyThIniQ+XpeYxhdu6Fi2zI67FwlXxMqtZ16L1Pm5kagHiOw3MaXZE1CSr4mPfVQP+6Ppfu9rr7b91ywloOEONqMzcRGpW4DEutjXM4sdADPURANScVd0QtW1 ppsud@sudipta"
}

resource "aws_key_pair" "PathnexKey" {
  key_name   = "PathnexKey"
  public_key = var.public_key
}

resource "aws_instance" "PathnexEC2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "c6i.8xlarge"
  key_name      = aws_key_pair.PathnexKey.key_name

  tags = {
    Name = "Pathnex-EC2"
  }
}
```

### Commands:
```bash
terraform init
terraform validate
terraform plan
```

---

## 3. 🔹 Kubernetes — Create ClusterIP Service (`service.yaml`)

### Overview
Creates a Kubernetes `ClusterIP` Service named `pathnex-service` that exposes pods labeled `app: pathnex-app` on port 80.

### Manifest:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: pathnex-service
spec:
  selector:
    app: pathnex-app
  ports:
    - port: 80
      targetPort: 80
```

### Verification:
```bash
kubectl apply -f service.yaml --dry-run=client
# Or to deploy:
kubectl apply -f service.yaml
kubectl get svc pathnex-service
```

---

## 4. 🔹 Jenkins Pipeline — Parallel Build & Test (`Jenkinsfile`)

### Overview
Demonstrates Jenkins Declarative Pipeline's `parallel` block to execute the `Build` and `Test` stages concurrently on agent executors, reducing overall pipeline execution time.

### Pipeline Script:
```groovy
pipeline {
    agent any
    stages {
        stage('Parallel Tasks') {
            parallel {
                stage('Build') {
                    steps {
                        sh 'mvn clean compile'
                    }
                }
                stage('Test') {
                    steps {
                        sh 'mvn test'
                    }
                }
            }
        }
    }
}
```

---

## 5. 🔹 GitLab CI — Parallel Jobs (`.gitlab-ci.yml`)

### Overview
Demonstrates running parallel jobs in GitLab CI. Both `maven-build` and `maven-test` belong to the same `build-test` stage and run concurrently on separate runner instances.

### Pipeline Configuration:
```yaml
stages:
  - build-test

maven-build:
  stage: build-test
  image: maven:3.8.1-jdk-17
  script:
    - git clone https://github.com/Pathnex/sample-java-app.git
    - cd sample-java-app
    - mvn clean compile
  parallel: 1

maven-test:
  stage: build-test
  image: maven:3.8.1-jdk-17
  script:
    - git clone https://github.com/Pathnex/sample-java-app.git
    - cd sample-java-app
    - mvn test
  parallel: 1
```

