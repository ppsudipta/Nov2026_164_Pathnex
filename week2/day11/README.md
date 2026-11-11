# Day 11 — Database, Outputs, Sidecars, Functions & Notifications

This directory contains the implementations for **Day 11 — Week 2**.

---

## 1. 🔹 Ansible — Install MariaDB (`install-mariadb.yml`)
- Installs `mariadb-server` via the `yum` package manager.
- Ensures the `mariadb` service is started and enabled at system boot.

```yaml
---
- name: Install MariaDB for Pathnex
  hosts: all
  become: yes

  tasks:
    - name: Install MariaDB
      yum:
        name: mariadb-server
        state: present

    - name: Start MariaDB
      service:
        name: mariadb
        state: started
        enabled: yes
```

---

## 2. 🔹 Terraform — Output Public IP (`main.tf`)
- Provisions an AWS EC2 instance (`r5.2xlarge`) tagged `Pathnex-Output-EC2`.
- Defines an output `PathnexPublicIP` exporting the public IP address upon provisioning.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "PathnexServer" {
  ami           = "ami-0abcd1234abcd1234"
  instance_type = "r5.2xlarge"

  tags = {
    Name = "Pathnex-Output-EC2"
  }
}

output "PathnexPublicIP" {
  description = "Public IP of the Pathnex Server"
  value       = aws_instance.PathnexServer.public_ip
}
```

---

## 3. 🔹 Kubernetes — Sidecar Container (`sidecar-pod.yaml`)
- Multi-container Pod `pathnex-sidecar` demonstrating the sidecar architectural pattern.
- Main container runs `nginx`.
- Auxiliary sidecar container runs `busybox` running diagnostic logs / background task.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pathnex-sidecar
spec:
  containers:
    - name: main
      image: nginx
    - name: sidecar
      image: busybox
      command: ["sh", "-c", "echo Sidecar running; sleep 3600"]
```

---

## 4. 🔹 Shell Script — Function Example (`function.sh`)
- Defines and executes a modular Bash function `greet`.

```bash
#!/bin/bash

greet() {
  echo "Welcome to Pathnex DevOps Training"
}

greet
```

---

## 5. 🔹 Jenkins Pipeline — Email Notifications (`Jenkinsfile`)
- Leverages the Jenkins `mail` step in post-action blocks (`success` and `failure`).
- Sends status emails to `team@pathnex.com` containing the build number and outcome.

```groovy
post {
    success {
        mail to: 'team@pathnex.com',
             subject: "SUCCESS: Build #${env.BUILD_NUMBER}",
             body: "Build completed successfully for $INSTITUTE_NAME"
    }
    failure {
        mail to: 'team@pathnex.com',
             subject: "FAILURE: Build #${env.BUILD_NUMBER}",
             body: "Build failed for $INSTITUTE_NAME"
    }
}
```

---

## 6. 🔹 GitLab CI — Notifications (`.gitlab-ci.yml`)
- Uses `after_script` to trigger an email notification step upon job execution completion.
