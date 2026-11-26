# Day 13 — DEBUG DAY (Week 2) & Matrix Builds

This directory contains the resolved and debugged configurations for **Day 13 — DEBUG DAY**.

---

## 1. 🔹 Ansible (`install-nginx.yml`)

### Root Cause Analysis (Bugs in Original File):
1. **Missing colon in name**: `- name "Broken"` was missing `:` (`- name: "Install nginx"`).
2. **Missing colon in parameter**: `state present` was missing `:` (`state: present`).
3. **Indentation**: Corrected indentation for `hosts: all` and `tasks`.

### Fixed Code:
```yaml
---
- name: "Install nginx"
  hosts: all
  become: yes
  tasks:
    - name: Install
      yum:
        name: nginx
        state: present
```

---

## 2. 🔹 Terraform (`main.tf`)

### Root Cause Analysis (Bugs in Original File):
1. **Typo in keyword**: `resouce` $\rightarrow$ must be `resource`.
2. **Unquoted resource identifier**: `BadEC2` $\rightarrow$ must be quoted string `"BadEC2"`.
3. **Unquoted string value**: `ami = ami-123` $\rightarrow$ must be quoted string `"ami-123"`.
4. **Invalid map delimiter**: `Name:"Broken"` $\rightarrow$ HCL maps use `=` assignments (`Name = "Broken"`), not `:`.

### Fixed Code:
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "BadEC2" {
  ami           = "ami-123"
  instance_type = "c5.large"

  tags = {
    Name = "Broken"
  }
}
```

---

## 3. 🔹 Kubernetes (`deployment.yaml`)

### Root Cause Analysis (Bugs in Original File):
1. **Missing colons across keys**:
   - `apiVersion apps/v1` $\rightarrow$ `apiVersion: apps/v1`
   - `kind Deployment` $\rightarrow$ `kind: Deployment`
   - `replicas 2` $\rightarrow$ `replicas: 2`
   - `app broken` $\rightarrow$ `app: broken`
   - `- name app` $\rightarrow$ `- name: app`
   - `image nginx` $\rightarrow$ `image: nginx`
2. **Indentation under `metadata` and `spec`**: Corrected standard 2-space indentation.

### Fixed Code:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broken
  template:
    metadata:
      labels:
        app: broken
    spec:
      containers:
        - name: app
          image: nginx
```

---

## 4. 🔹 Jenkins Pipeline — Matrix Build (`Jenkinsfile`)

### Root Cause Analysis & Fix:
- In Jenkins Declarative Pipeline syntax, `matrix { ... }` blocks cannot be placed directly under the root `pipeline` block without an enclosing `stage` inside `stages`.
- Wrapped `matrix` in `stage('Matrix Build')` to make the Declarative syntax valid.

```groovy
pipeline {
    agent any
    environment {
        INSTITUTE_NAME = "Pathnex"
    }
    stages {
        stage('Matrix Build') {
            matrix {
                axes {
                    axis {
                        name 'JAVA_VERSION'
                        values '8', '11', '17'
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            sh "echo Building with Java ${JAVA_VERSION}"
                        }
                    }
                }
            }
        }
    }
}
```

---

## 5. 🔹 GitLab CI — Matrix Jobs (`.gitlab-ci.yml`)
- Executes matrix builds in parallel across multiple Java versions (`['8', '11', '17']`).

```yaml
stages:
  - build

build:
  stage: build
  image: maven:3.8.1-jdk-17
  parallel:
    matrix:
      - JAVA_VERSION: ['8', '11', '17']
  script:
    - echo "Building with Java $JAVA_VERSION"
```
