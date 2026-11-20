# Day 09 — Templates, Internet Gateway, ConfigMap, CPU Load & Artifacts

This directory contains the implementations for **Day 09 — Week 2**.

---

## 1. 🔹 Ansible — Jinja2 Template (`deploy-template.yml`)
- Deploys a configuration file `/etc/pathnex.conf` from the Jinja2 template `pathnex.conf.j2`.
- Demonstrates dynamic configuration management using Ansible templates.

```yaml
---
- name: Deploy template for Pathnex
  hosts: all
  become: yes

  tasks:
    - name: Copy template file
      template:
        src: pathnex.conf.j2
        dest: /etc/pathnex.conf
```

---

## 2. 🔹 Terraform — Internet Gateway (`main.tf`)
- Creates an AWS Internet Gateway `aws_internet_gateway.PathnexIGW` attached to the `PathnexVPC` (`10.10.0.0/16`).
- Establishes external internet connectivity capability for the VPC's subnets.

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

resource "aws_internet_gateway" "PathnexIGW" {
  vpc_id = aws_vpc.PathnexVPC.id

  tags = {
    Name = "Pathnex-IGW"
  }
}
```

---

## 3. 🔹 Kubernetes — ConfigMap (`configmap.yaml`)
- Creates a Kubernetes ConfigMap `pathnex-config`.
- Stores key-value application configuration settings:
  - `APP_MODE: "production"`
  - `WELCOME_MSG: "Hello Pathnex"`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: pathnex-config
data:
  APP_MODE: "production"
  WELCOME_MSG: "Hello Pathnex"
```

---

## 4. 🔹 Shell Script — Check CPU Load (`cpu_load.sh`)
- Extracts and prints the 1-minute CPU load average from `uptime` using `awk`.

```bash
#!/bin/bash

LOAD=$(uptime | awk '{print $10}')

echo "Current CPU Load: $LOAD"
```

---

## 5. 🔹 Jenkins Pipeline — Archive Artifacts (`Jenkinsfile`)
- Checks out code and packages the Java application with `mvn clean package`.
- Archives compiled `.jar` binaries matching `target/*.jar` with fingerprinting enabled for traceability across builds.

```groovy
pipeline {
    agent any
    environment {
        INSTITUTE_NAME = "Pathnex"
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Pathnex/sample-java-app.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
```

---

## 6. 🔹 GitLab CI — Artifacts (`.gitlab-ci.yml`)
- Executes Maven package step on the Java application.
- Configures `artifacts` retention of packaged `.jar` files with `expire_in: 1 week`.
