<<<<<<< HEAD
# DevOps Practical Task: LAMP Stack Deployment & Automation

| Task | Folder | What it proves |
|---|---|---|
| 1. Docker | `task1-docker/` | Dockerfile, Nginx+PHP-FPM, MySQL container, PHP→MySQL connection |
| 2. Kubernetes | `task2-k8s/` | Deployment, StatefulSet, PV/PVC, Secrets/ConfigMaps, HPA, probes, rolling updates |
| 3. Terraform + Ansible (bonus) | `task3-terraform-ansible/` | EC2 provisioning, security groups, IAM, config management |

Each folder has its own README with exact commands. Suggested order to
work through and demo them: Task 1 → Task 2 → Task 3.

## Submitting to GitHub
```bash
cd lamp-devops-task
git init
git add .
git commit -m "DevOps practical task: Docker, Kubernetes, Terraform/Ansible"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```
Consider a `.gitignore` excluding `.terraform/`, `*.tfstate*`, and any
`.pem` key files so you never commit secrets or local Terraform state.
=======
# LAMP_Stack_Deployment_And_Automation
LAMP Stack Deployment &amp; Automation
>>>>>>> c8ed5d2a65fba353801b985770bf44fe8da4c042
