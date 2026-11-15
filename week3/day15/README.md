# Day 15 — Java, S3 Bucket, CronJob, File Reader

This directory contains the implementations for **Day 15 — Week 3**.

---

## 1. 🔹 Ansible — Install Java & Set JAVA_HOME (`install-java.yml`)
- Installs OpenJDK 11 with `yum`.
- Sets `JAVA_HOME` in `/etc/profile` via `lineinfile`.

```bash
ansible-playbook -i inventory.ini install-java.yml
```

---

## 2. 🔹 Terraform — Create S3 Bucket (`main.tf`)
- Creates `aws_s3_bucket.PathnexBucket` named `pathnex-devops-bucket` in `us-east-1`.
- Run against **your own AWS account** (bucket names are globally unique — change the name if taken).

```bash
terraform init
terraform plan
terraform apply
```

---

## 3. 🔹 Kubernetes — CronJob (`cronjob.yaml`)
- Schedules a busybox job every 5 minutes that prints `Pathnex CronJob running`.

```bash
kubectl apply -f cronjob.yaml
```

---

## 4. 🔹 Shell Script — Read File Line-by-Line (`read_passwd.sh`)
- Reads `/etc/passwd` line by line and echoes each line.

```bash
chmod +x read_passwd.sh
./read_passwd.sh
```

---

## 5. 🔹 Jenkins Pipeline — Slack Notification (`Jenkinsfile`)
- Builds `sample-java-app` with Maven.
- Sends Slack messages on success and failure via `slackSend`.

---

## 6. 🔹 GitLab CI — Slack Notification (`.gitlab-ci.yml`)
- Clones and packages the sample Java app.
- Posts a Slack webhook notification after a successful build (replace the placeholder webhook URL).
