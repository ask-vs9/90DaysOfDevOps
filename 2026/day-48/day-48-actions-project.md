# Day 48 – GitHub Actions Project: End-to-End CI/CD Pipeline

## Overview

Day 48 focused on building an end-to-end CI/CD pipeline using GitHub Actions.

The project combines GitHub Actions, reusable workflows, Python Flask, Docker, Docker Hub, Trivy security scanning, Pull Request validation, production deployment flow, scheduled health checks, artifacts, and GitHub Step Summary.

The goal was to create a practical CI/CD pipeline where Pull Requests are tested first, changes merged into `main` are built into a Docker image, the image is security-scanned and pushed to Docker Hub, and a deployment job runs after successful validation.

---

# Part 1 – Project Setup

## Task 1 – Create the Project Repository

The hands-on project was implemented in the existing repository:

https://github.com/ask-vs9/github-actions-practice

The project is a simple Flask application with a `/` endpoint and a `/health` endpoint.

## Application Structure

```text
github-actions-practice/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── test_app.py
│
├── .github/
│   └── workflows/
│       ├── reusable-build-test.yml
│       ├── reusable-docker.yml
│       ├── pr-pipeline.yml
│       ├── main-pipeline.yml
│       └── health-check.yml
│
├── Dockerfile
└── README.md
```

---

# Part 2 – Flask Application

## Task 2 – Application

### `app/app.py`

```python
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "message": "GitHub Actions Capstone is running!"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

The application provides:

```text
/        -> Application endpoint
/health  -> Health check endpoint
```

## Task 3 – Python Dependencies

### `app/requirements.txt`

```text
Flask==3.1.2
```

## Task 4 – Application Test

### `app/test_app.py`

```python
import unittest

from app import app


class TestHealthEndpoint(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()

    def test_health(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["status"], "healthy")


if __name__ == "__main__":
    unittest.main()
```

The test verifies that the `/health` endpoint returns HTTP `200` and the expected healthy status.

---

# Part 3 – Docker

## Task 5 – Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update     && apt-get upgrade -y     && rm -rf /var/lib/apt/lists/*

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]
```

## Docker Build

```bash
docker build --no-cache -t github-actions-capstone:latest .
```

The Docker image built successfully.

## Local Application Test

```bash
docker run -d   --name capstone-app   -p 5000:5000   github-actions-capstone:latest
```

Health endpoint:

```bash
curl http://localhost:5000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

---

# Part 4 – Reusable Build and Test Workflow

## Task 6 – Reusable Workflow

### `.github/workflows/reusable-build-test.yml`

```yaml
name: Reusable Build and Test

on:
  workflow_call:
    inputs:
      python_version:
        description: "Python version to use"
        required: false
        type: string
        default: "3.12"

      run_tests:
        description: "Whether to run tests"
        required: false
        type: boolean
        default: true

    outputs:
      test_result:
        description: "Result of the test execution"
        value: ${{ jobs.build-test.outputs.test_result }}

jobs:
  build-test:
    runs-on: ubuntu-latest

    outputs:
      test_result: ${{ steps.test-result.outputs.test_result }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v6
        with:
          python-version: ${{ inputs.python_version }}

      - name: Install Dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r app/requirements.txt

      - name: Run Tests
        if: inputs.run_tests
        id: run-tests
        run: |
          python app/test_app.py

      - name: Set Test Result
        id: test-result
        if: always()
        run: |
          if [ "${{ steps.run-tests.outcome }}" = "success" ]; then
            echo "test_result=passed" >> "$GITHUB_OUTPUT"
          else
            echo "test_result=failed" >> "$GITHUB_OUTPUT"
          fi
```

This workflow centralizes application build and test logic so it can be reused by multiple pipelines.

---

# Part 5 – Reusable Docker Build and Push Workflow

## Task 7 – Docker Build, Push and Security Scan

### `.github/workflows/reusable-docker.yml`

```yaml
name: Reusable Docker Build and Push

on:
  workflow_call:
    inputs:
      image_name:
        description: "Docker Hub image name"
        required: true
        type: string

      tag:
        description: "Docker image tag"
        required: true
        type: string

    secrets:
      docker_username:
        description: "Docker Hub username"
        required: true

      docker_token:
        description: "Docker Hub access token"
        required: true

    outputs:
      image_url:
        description: "Full Docker image URL"
        value: ${{ jobs.docker.outputs.image_url }}

jobs:
  docker:
    runs-on: ubuntu-latest

    outputs:
      image_url: ${{ steps.image.outputs.image_url }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.docker_username }}
          password: ${{ secrets.docker_token }}

      - name: Set Short SHA
        id: vars
        shell: bash
        run: |
          echo "short_sha=${GITHUB_SHA::7}" >> "$GITHUB_OUTPUT"

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ${{ inputs.image_name }}:${{ inputs.tag }}
            ${{ inputs.image_name }}:sha-${{ steps.vars.outputs.short_sha }}

      - name: Scan Docker Image with Trivy
        uses: aquasecurity/trivy-action@v0.36.0
        with:
          version: v0.74.0
          scan-type: image
          image-ref: ${{ inputs.image_name }}:${{ inputs.tag }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL
          exit-code: 1

      - name: Upload Trivy Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: trivy-results
          path: trivy-results.sarif

      - name: Set Image URL
        id: image
        run: |
          echo "image_url=${{ inputs.image_name }}:${{ inputs.tag }}" >> "$GITHUB_OUTPUT"
```

Docker Hub image:

https://hub.docker.com/r/ask09/github-actions-capstone

Generated tags:

```text
latest
sha-<short-commit-sha>
```

---

# Part 6 – Trivy Security Scanning

## Task 8 – Container Security

Trivy was added as a security gate.

The workflow scans the Docker image for `CRITICAL` vulnerabilities:

```yaml
severity: CRITICAL
exit-code: 1
```

The Trivy report is uploaded as a GitHub Actions artifact:

```yaml
if: always()
```

## Local Trivy

Trivy was installed using:

```bash
winget install AquaSecurity.Trivy
```

Version:

```bash
trivy --version
```

```text
Version: 0.74.0
```

## Local Scan

```bash
trivy image --severity CRITICAL github-actions-capstone:latest
```

The final local scan reported zero CRITICAL vulnerabilities.

---

# Part 7 – Pull Request Pipeline

## Task 9 – PR Pipeline

### `.github/workflows/pr-pipeline.yml`

```yaml
name: PR Pipeline

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

jobs:
  build-test:
    name: Build and Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      python_version: "3.12"
      run_tests: true

  pr-comment:
    name: PR Check Message
    needs: build-test
    runs-on: ubuntu-latest
    steps:
      - name: Show PR Check Result
        run: |
          echo "PR checks passed for branch: ${{ github.head_ref }}"
```

PR flow:

```text
Pull Request
      |
      v
Reusable Build & Test
      |
      v
PR Check Message
```

The PR pipeline was tested successfully using:

```text
feature/day48-cicd-pipeline
```

The Pull Request was merged into `main`, and the feature branch was deleted.

---

# Part 8 – Main Branch CI/CD Pipeline

## Task 10 – Main Pipeline

### `.github/workflows/main-pipeline.yml`

```yaml
name: Main Branch Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-test:
    name: Build and Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      python_version: "3.12"
      run_tests: true

  docker:
    name: Build and Push Docker Image
    needs: build-test
    uses: ./.github/workflows/reusable-docker.yml
    with:
      image_name: ask09/github-actions-capstone
      tag: latest
    secrets:
      docker_username: ${{ secrets.DOCKER_USERNAME }}
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  deploy:
    name: Deploy to Production
    needs: docker
    runs-on: ubuntu-latest
    environment:
      name: production
    steps:
      - name: Deploy Application
        run: |
          echo "Deploying image: ${{ needs.docker.outputs.image_url }} to production"
          echo "Deployment completed successfully."
```

Pipeline:

```text
Push to main
     |
     v
Build & Test
     |
     v
Docker Build & Push
     |
     v
Trivy Security Scan
     |
     v
Deploy to Production
```

The deployment job uses the `production` environment and depends on the Docker job.

---

# Part 9 – Scheduled Health Check

## Task 11 – Health Check

### `.github/workflows/health-check.yml`

```yaml
name: Scheduled Health Check

on:
  schedule:
    - cron: '0 */12 * * *'
  workflow_dispatch:

jobs:
  health-check:
    name: Docker Health Check
    runs-on: ubuntu-latest

    steps:
      - name: Pull Latest Docker Image
        run: |
          docker pull ask09/github-actions-capstone:latest

      - name: Start Container
        run: |
          docker run -d             --name capstone-health-check             -p 5000:5000             ask09/github-actions-capstone:latest

      - name: Wait for Application
        run: |
          echo "Waiting for application to start..."
          sleep 5

      - name: Check Health Endpoint
        shell: bash
        run: |
          HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health)
          echo "HTTP response code: $HTTP_STATUS"

          if [ "$HTTP_STATUS" -eq 200 ]; then
            echo "Health check passed."
            echo "## Health Check Result" >> "$GITHUB_STEP_SUMMARY"
            echo "Application health endpoint returned HTTP 200." >> "$GITHUB_STEP_SUMMARY"
          else
            echo "Health check failed."
            echo "## Health Check Result" >> "$GITHUB_STEP_SUMMARY"
            echo "Application health endpoint returned HTTP $HTTP_STATUS." >> "$GITHUB_STEP_SUMMARY"
            exit 1
          fi

      - name: Stop and Remove Container
        if: always()
        run: |
          docker stop capstone-health-check || true
          docker rm capstone-health-check || true
```

Schedule:

```text
0 */12 * * *
```

Manual execution is enabled with:

```yaml
workflow_dispatch:
```

The health check was manually triggered and completed successfully.

---

# Part 10 – GitHub Actions Secrets

Docker credentials are stored in GitHub repository secrets:

```text
DOCKER_USERNAME
DOCKER_TOKEN
```

They are passed into the reusable Docker workflow without hard-coding credentials.

---

# Part 11 – Architecture

```text
                         Developer
                             |
                             v
                    Pull Request to main
                             |
                             v
                +-------------------------+
                |      PR Pipeline        |
                +-------------------------+
                             |
                             v
                +-------------------------+
                | Reusable Build & Test   |
                +-------------------------+
                             |
                             v
                       PR Validation
                             |
                           Merge
                             |
                             v
                       Push to main
                             |
                             v
                +-------------------------+
                | Reusable Build & Test   |
                +-------------------------+
                             |
                             v
                +-------------------------+
                | Reusable Docker         |
                | Build & Push            |
                +-------------------------+
                             |
                             v
                +-------------------------+
                | Trivy Security Scan     |
                | CRITICAL vulnerabilities|
                +-------------------------+
                             |
                         Scan Pass
                             |
                             v
                +-------------------------+
                | Deploy to Production    |
                +-------------------------+
                             |
                             v
                         Docker Hub
                             |
                             v
                  Scheduled Health Check
                             |
                             v
                       /health -> 200
```

---

# Part 12 – CI/CD Workflow Comparison

| Workflow | Trigger | Purpose |
|---|---|---|
| Reusable Build and Test | `workflow_call` | Reusable application build and testing |
| Reusable Docker Build and Push | `workflow_call` | Build, scan and push Docker image |
| PR Pipeline | Pull Request | Validate Pull Requests |
| Main Branch Pipeline | Push to `main` | Build, scan, push and deploy |
| Scheduled Health Check | Cron / Manual | Verify container health |

---

# Part 13 – Workflow Outputs

The Build and Test workflow exposes:

```yaml
outputs:
  test_result:
```

The Docker workflow exposes:

```yaml
outputs:
  image_url:
```

The main pipeline consumes the Docker output:

```yaml
${{ needs.docker.outputs.image_url }}
```

This demonstrates communication between reusable workflows and caller jobs.

---

# Part 14 – GitHub Actions Results

## Pull Request Pipeline

```text
PR #3
Branch: feature/day48-cicd-pipeline

Build and Test       PASS
PR Check Message     PASS
```

## Main Branch Pipeline

```text
Build and Test            PASS
Docker Build & Push       PASS
Trivy Security Scan       PASS
Deploy to Production      PASS
```

## Health Check

```text
Docker image pull       PASS
Container start         PASS
Health endpoint         PASS
HTTP response           200
Container cleanup       PASS
```

---

# Part 15 – README Badges

The project README contains six workflow badges:

```markdown
[![Reusable Build and Test](https://github.com/ask-vs9/github-actions-practice/actions/workflows/reusable-build-test.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/reusable-build-test.yml)

[![Reusable Docker Build and Push](https://github.com/ask-vs9/github-actions-practice/actions/workflows/reusable-docker.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/reusable-docker.yml)

[![PR Pipeline](https://github.com/ask-vs9/github-actions-practice/actions/workflows/pr-pipeline.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/pr-pipeline.yml)

[![Main Branch Pipeline](https://github.com/ask-vs9/github-actions-practice/actions/workflows/main-pipeline.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/main-pipeline.yml)

[![Scheduled Health Check](https://github.com/ask-vs9/github-actions-practice/actions/workflows/health-check.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/health-check.yml)

[![Smart Path Triggers](https://github.com/ask-vs9/github-actions-practice/actions/workflows/smart-triggers.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/smart-triggers.yml)
```

---

# Part 16 – Files Created

```text
app/app.py
app/requirements.txt
app/test_app.py
Dockerfile
README.md

.github/workflows/reusable-build-test.yml
.github/workflows/reusable-docker.yml
.github/workflows/pr-pipeline.yml
.github/workflows/main-pipeline.yml
.github/workflows/health-check.yml
```

Documentation:

```text
2026/day-48/day-48-actions-project.md
```

---

# Part 17 – Security and Best Practices

The project demonstrates:

- GitHub Secrets for Docker credentials
- Reusable GitHub Actions workflows
- Dependency pinning
- Docker image tagging
- Trivy container security scanning
- GitHub Actions artifact collection
- Production environment configuration
- Job dependencies using `needs`
- Scheduled health monitoring
- Manual workflow dispatch

---

# Part 18 – Key Takeaways

Day 48 provided hands-on experience with:

- GitHub Actions CI/CD
- Reusable workflows
- `workflow_call`
- Workflow inputs
- Workflow secrets
- Workflow outputs
- Pull Request pipelines
- Main branch pipelines
- Docker Buildx
- Docker Hub
- Docker image tagging
- Trivy container scanning
- GitHub Actions artifacts
- Production environments
- Scheduled workflows
- Manual workflow dispatch
- Health checks
- Job dependencies using `needs`
- End-to-end CI/CD architecture

The major concept was separating reusable CI/CD logic from caller workflows.

Instead of duplicating build and test steps, the same reusable workflow can be called from multiple pipelines.

---

# Part 19 – What Happens in the Pipeline?

## Pull Request

```text
Developer creates PR
        |
        v
PR Pipeline starts
        |
        v
Reusable Build & Test
        |
        v
Tests pass
        |
        v
PR validation completes
```

No Docker image is pushed from the PR pipeline.

## Main Branch

```text
PR merged
     |
     v
Push to main
     |
     v
Build & Test
     |
     v
Docker Build
     |
     v
Docker Push
     |
     v
Trivy Scan
     |
     v
Deploy
```

## Health Monitoring

```text
Every 12 hours
      |
      v
Pull latest image
      |
      v
Start container
      |
      v
Wait for application
      |
      v
curl /health
      |
      v
HTTP 200
      |
      v
Health Check Passed
```

---

# Part 20 – Improvements and Next Steps

## Slack Notifications

Add notifications for:

- Build failures
- Deployment success
- Deployment failures
- Health check failures

## Multi-Environment Deployment

Introduce:

```text
Development
     |
     v
Staging
     |
     v
Production
```

with environment-specific configuration and approvals.

## Rollback Strategy

Use previous Docker image tags for rollback:

```text
sha-previous
sha-current
```

## Kubernetes Deployment

The Docker image can be deployed to Kubernetes or Amazon EKS.

## Infrastructure as Code

Terraform can provision:

- AWS infrastructure
- EKS
- IAM
- VPC
- Load Balancers

## Advanced Security

Future security improvements can include:

- SAST
- Dependency scanning
- Secret scanning
- SBOM generation
- Image signing
- Policy enforcement

---

# Part 21 – Screenshots

## Pull Request Pipeline

![Day 48 - Pull Request Pipeline](./Screenshot%202026-09-15%20161753%281%29.png)

## Main Branch Pipeline

![Day 48 - Main Branch Pipeline](./Screenshot%202026-09-15%20162030%281%29.png)

## Trivy Security Scan

Add the Trivy scan result screenshot here.

```text
Trivy security scan completed successfully with zero CRITICAL vulnerabilities in the final local scan.
```

## Health Check

![Day 48 - Scheduled Health Check](./Screenshot%202026-09-15%20162857%281%29.png)

# Part 22 – GitHub Repositories

## GitHub Actions Practice

https://github.com/ask-vs9/github-actions-practice

## 90DaysOfDevOps

https://github.com/ask-vs9/90DaysOfDevOps

## Docker Hub

https://hub.docker.com/r/ask09/github-actions-capstone

---

# Day 48 Summary

Day 48 focused on building an end-to-end GitHub Actions CI/CD pipeline.

The project started with a simple Flask application and Dockerfile. A reusable Build and Test workflow was created to centralize application testing.

A second reusable workflow was created for Docker image building, tagging, pushing to Docker Hub, and Trivy security scanning.

The Pull Request pipeline validates application changes without pushing Docker images.

The main branch pipeline performs:

```text
Build & Test
    ->
Docker Build & Push
    ->
Trivy Security Scan
    ->
Deploy to Production
```

A scheduled health-check workflow verifies that the Docker image can start successfully and that the `/health` endpoint returns HTTP 200.

This project provided practical experience with reusable GitHub Actions workflows, CI/CD architecture, Docker, Docker Hub, security scanning, deployment environments, workflow outputs, secrets, artifacts, and scheduled automation.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
