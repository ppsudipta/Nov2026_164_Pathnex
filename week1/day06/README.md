# Day 06 — DEBUG DAY Solution & Analysis

This directory contains the resolved and debugged configurations for **Day 06 — DEBUG DAY**.

---

## 1. 🔹 Ansible (`install-nginx.yml`)

### Root Cause Analysis (Bugs in Original File):
1. **Missing colon after play name**: `- name Install nginx` was missing the `:` delimiter (`- name: Install nginx`).
2. **Missing colon in `hosts`**: `hosts all` was missing the `:` delimiter (`hosts: all`).
3. **Missing colon in `become`**: `become yes` was missing the `:` delimiter (`become: yes`).
4. **Missing whitespace in task list**: `-name: Install nginx` was missing space between `-` and `name` (`- name: Install nginx`).
5. **Indentation and missing colons in task parameters**:
   - `name nginx` was missing `:` (`name: nginx`).
   - `state present` was missing `:` (`state: present`).
   - `yum:` and task parameters were improperly indented relative to the task list item.

### Fixed Code:
```yaml
---
- name: Install nginx
  hosts: all
  become: yes
  tasks:
    - name: Install nginx
      yum:
        name: nginx
        state: present
```

---

## 2. 🔹 Terraform (`main.tf`)

### Root Cause Analysis (Bugs in Original File):
1. **Unquoted string literal**: `instance_type = t2.micro` was unquoted. In HCL2, instance types must be quoted strings (`"t2.micro"`). Unquoted references are evaluated as undeclared variables or identifiers, causing syntax/evaluation errors.
2. **Invalid block syntax for map argument**: `tags { Name = "Broken" }` used block syntax. In the `aws_instance` resource, `tags` is a map argument requiring an assignment operator (`tags = { ... }`).
3. **Missing provider declaration**: Added the AWS provider block with a region for standard Terraform configuration validity.

### Fixed Code:
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "BrokenEC2" {
  ami           = "ami-0xyz"
  instance_type = "t2.micro"

  tags = {
    Name = "Broken"
  }
}
```

---

## 3. 🔹 Kubernetes (`pod.yaml`)

### Root Cause Analysis (Bugs in Original File):
1. **Missing colons in root keys**: `apiVersion v1`, `kind Pod`, and `spec` were missing colons (`apiVersion: v1`, `kind: Pod`, `spec:`).
2. **Missing colon and indentation in metadata**: `name pathnex` had no colon and improper indentation under `metadata:`.
3. **Missing colons and indentation in container spec**:
   - `containers:` was not properly indented under `spec:`.
   - `- name app` was missing colon (`- name: app`).
   - `image nginx` was missing colon (`image: nginx`).

### Fixed Code:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pathnex
spec:
  containers:
    - name: app
      image: nginx
```

---

## 4. 🔹 Jenkins Pipeline — Debugging (`Jenkinsfile`)

### Root Cause Analysis & Improvements:
1. **Brittle Shell Error Handling**:
   - The original pipeline used `mvn clean compile || { echo "Compile failed"; exit 1; }` inside `sh '''...'''`.
   - In Declarative Pipelines, the native and robust way to handle stage failures is using `post { failure { ... } success { ... } }` blocks rather than shell-level traps that obscure error reporting.
2. **Handling Test Failures Gracefully (`catchError` & JUnit Reports)**:
   - When unit tests fail in `mvn test`, terminating immediately without saving reports prevents developers from diagnosing what broke.
   - Added `catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE')` and `junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'` inside `post { always { ... } }` so test reports are always captured and visualized in the Jenkins UI.
3. **Tools Block**:
   - Configured `tools` block for `maven` and `jdk` so Maven and Java binaries are available in PATH across build agents.
4. **Pipeline Lifecycle Notifications**:
   - Added global `post` actions (`cleanWs()`, status alerts) for workspace hygiene and visibility.

---

## 5. 🔹 GitLab CI — Debugging (`.gitlab-ci.yml`)

### Root Cause Analysis & Improvements:
1. **Job Isolation & Missing Artifacts (Critical Error)**:
   - In GitLab CI, jobs (`build` and `test`) execute in independent, isolated container instances.
   - The original pipeline cloned `sample-java-app` in `build`, but did not export any artifacts. When `test` ran, `cd sample-java-app` failed with `cd: sample-java-app: No such file or directory`.
   - **Fix**: Added `artifacts: paths: [sample-java-app/]` to the `build` job and `dependencies: [build]` to `test`.
2. **Handling Job Failures & Exit Codes**:
   - The original code hardcoded `exit 1` on error (`mvn test || { echo "Tests failed"; exit 1; }`), which overwrites Maven's actual return code.
   - Used `EXIT_CODE=$?` to log the exact error code and preserve it for the CI runner.
   - Configured `after_script` to check `$CI_JOB_STATUS` (`failed` vs `success`) for clear diagnostics.
   - Added JUnit test report collection (`artifacts: reports: junit: ...`) with `when: always` so test results are rendered natively in GitLab MRs and pipeline dashboards even when tests fail.
   - Added dependency caching (`.m2/repository`) for performance.
