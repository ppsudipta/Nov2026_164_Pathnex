# Day 10 — Conditions, Route Table, Secret, Loops & Caching Dependencies

This directory contains the implementations for **Day 10 — Week 2**.

---

## 1. 🔹 Ansible — When Condition (`install-conditional.yml`)
- Uses the `when` condition to inspect `ansible_facts['os_family'] == "RedHat"`.
- Ensures package installation (`htop`) is only attempted on RedHat-family systems.

```yaml
---
- name: Install tool based on OS
  hosts: all
  become: yes

  tasks:
    - name: Install htop
      yum:
        name: htop
        state: present
      when: ansible_facts['os_family'] == "RedHat"
```

---

## 2. 🔹 Terraform — Route Table + Association (`main.tf`)
- Defines `aws_route_table.PathnexRT` routing `0.0.0.0/0` outbound traffic through `aws_internet_gateway.PathnexIGW`.
- Associates the public subnet `aws_subnet.PathnexSubnet` with the route table via `aws_route_table_association.PathnexRTA`.

```hcl
resource "aws_route_table" "PathnexRT" {
  vpc_id = aws_vpc.PathnexVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PathnexIGW.id
  }

  tags = {
    Name = "Pathnex-RouteTable"
  }
}

resource "aws_route_table_association" "PathnexRTA" {
  subnet_id      = aws_subnet.PathnexSubnet.id
  route_table_id = aws_route_table.PathnexRT.id
}
```

---

## 3. 🔹 Kubernetes — Secret (`secret.yaml`)
- Creates an Opaque Kubernetes Secret `pathnex-secret`.
- Stores base64-encoded credentials (`password: cGF0aG5leDEyMw==`).

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: pathnex-secret
type: Opaque
data:
  password: cGF0aG5leDEyMw==   # "pathnex123" base64
```

---

## 4. 🔹 Shell Script — For Loop 1–10 (`loop_1_to_10.sh`)
- Iterates integers 1 through 10 using bash brace expansion `{1..10}`.

```bash
#!/bin/bash

for i in {1..10}; do
  echo "Number: $i"
done
```

---

## 5. 🔹 Jenkins Pipeline — Cache Maven Dependencies (`Jenkinsfile`)
- Inspects whether `.m2` directory exists before compiling.
- Reuses cached Maven artifacts to accelerate pipeline execution times.

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
                sh '''
                if [ -d ".m2" ]; then
                    echo "Using cached dependencies"
                else
                    mvn clean compile
                fi
                '''
            }
        }
    }
}
```

---

## 6. 🔹 GitLab CI — Cache Dependencies (`.gitlab-ci.yml`)
- Configures caching with cache key `maven-cache` for path `.m2/repository`.
- Preserves Maven repository dependencies between pipeline runs.

```yaml
stages:
  - build

build:
  stage: build
  image: maven:3.8.1-jdk-17
  cache:
    key: maven-cache
    paths:
      - .m2/repository
  script:
    - git clone https://github.com/Pathnex/sample-java-app.git
    - cd sample-java-app
    - mvn clean compile
```
