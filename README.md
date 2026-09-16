# Banking Domain Application — CI/CD Pipeline & Deployment Automation

A DevOps project demonstrating end-to-end CI/CD pipeline automation, containerisation,
cloud deployment, and monitoring for a core banking transaction service.

## Project Overview

| Layer | Tools |
|---|---|
| CI/CD | Jenkins, GitHub Actions |
| Containerisation | Docker, Docker Compose |
| Cloud | AWS EC2, S3, IAM, CloudWatch |
| Version Control | Git, GitHub |
| Scripting | Bash |
| App | Python (Flask) |

## Project Structure

```
banking-devops-pipeline/
├── app/
│   ├── app.py
│   └── requirements.txt
├── scripts/
│   ├── deploy.sh
│   ├── log-rotation.sh
│   └── restart-check.sh
├── .github/workflows/ci-cd.yml
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── .gitignore
└── README.md
```

## How to Run Locally

```bash
git clone https://github.com/saisreeyadav1703-lgt/banking-devops-pipeline.git
cd banking-devops-pipeline
docker compose up -d
docker ps
curl http://localhost:8080/health
```

## Security Practices

- Non-root user inside Docker container
- Pinned base image versions (no `latest`)
- Secrets injected via environment variables
- `.gitignore` excludes `.env`, logs, credentials
- AWS security group: only ports 22, 80, 443 exposed
- SSH restricted to office IPs only

## Monitoring

- AWS CloudWatch — CPU utilisation and 5xx error rate alerts
- Health endpoint — `GET /health` returns 200 when service is ready

*Project by Yadava Saisree —*
