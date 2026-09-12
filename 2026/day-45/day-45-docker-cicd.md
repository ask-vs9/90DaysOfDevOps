# Day 45 – Docker Build & Push in GitHub Actions

## Overview

Day 45 focused on building a complete Docker CI/CD pipeline using GitHub Actions.

The objective was to automatically build a Docker image whenever code is pushed to GitHub and publish the image to Docker Hub.

The implementation covered:

* Building a Docker image locally
* Building the Docker image in GitHub Actions
* Authenticating with Docker Hub using GitHub Secrets
* Tagging Docker images
* Pushing images to Docker Hub
* Building images on feature branches without pushing
* Publishing images only from the `main` branch
* Pulling and running the published Docker image
* Adding a GitHub Actions status badge

---

## Task 1 – Prepare

Created a `Dockerfile` in the `github-actions-practice` repository.

### Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY test_script.py .

CMD ["python", "test_script.py"]
```

The Dockerfile uses Python 3.12 Slim as the base image and runs the existing `test_script.py` application inside the container.

### Build Docker Image Locally

```bash
docker build -t day45-docker-cicd .
```

The Docker image was successfully built.

### Run Docker Container Locally

```bash
docker run --rm day45-docker-cicd
```

Output:

```text
Test passed
```

This confirmed that the Docker image was working correctly before integrating it with GitHub Actions.

### Docker Hub Repository

Created the Docker Hub repository:

```text
ask09/day45-docker-cicd
```

Docker Hub:

https://hub.docker.com/r/ask09/day45-docker-cicd

### GitHub Secrets

The following GitHub repository secrets were used:

```text
DOCKER_USERNAME
DOCKER_TOKEN
```

These credentials are used to authenticate GitHub Actions with Docker Hub.

---

## Task 2 – Build the Docker Image in CI

Created the workflow:

```text
.github/workflows/docker-publish.yml
```

The workflow automatically runs whenever code is pushed to the repository.

### Complete Workflow

```yaml
name: Day 45 - Docker Build and Push

on:
  push:

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Set Short SHA
        id: vars
        shell: bash
        run: echo "short_sha=${GITHUB_SHA::7}" >> "$GITHUB_OUTPUT"

      - name: Login to Docker Hub
        if: github.ref == 'refs/heads/main'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: |
            ask09/day45-docker-cicd:latest
            ask09/day45-docker-cicd:sha-${{ steps.vars.outputs.short_sha }}
```

### Workflow Steps

The workflow performs the following:

1. Checks out the source code.
2. Sets up Docker Buildx.
3. Generates a short Git commit SHA.
4. Logs in to Docker Hub when running on `main`.
5. Builds the Docker image.
6. Tags the image as `latest`.
7. Creates a commit-specific image tag.
8. Pushes the image only when running on `main`.

The GitHub Actions workflow completed successfully and the Docker image was built in CI.

---

## Task 3 – Push to Docker Hub

Docker Hub authentication was configured using GitHub Secrets.

### Docker Hub Login

```yaml
- name: Login to Docker Hub
  if: github.ref == 'refs/heads/main'
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_TOKEN }}
```

The Docker Hub credentials are not hardcoded in the workflow.

### Docker Image Tags

The workflow creates two tags:

```text
ask09/day45-docker-cicd:latest
```

and:

```text
ask09/day45-docker-cicd:sha-<short-commit-sha>
```

Docker Hub successfully received the images.

Tags verified in Docker Hub included:

```text
latest
sha-564e5bd
sha-5564e5bd
```

This confirms that the GitHub Actions workflow successfully built and published Docker images.

### Docker Hub Repository

https://hub.docker.com/r/ask09/day45-docker-cicd

---

## Task 4 – Only Push on Main

The workflow is configured to build the Docker image on pushes to branches, but Docker Hub publishing is restricted to the `main` branch.

### Docker Hub Login Condition

```yaml
if: github.ref == 'refs/heads/main'
```

### Docker Push Condition

```yaml
push: ${{ github.ref == 'refs/heads/main' }}
```

This creates the following behavior:

```text
main branch
    ↓
Build Docker Image
    ↓
Login to Docker Hub
    ↓
Push Docker Image
```

For a feature branch:

```text
feature branch
    ↓
Build Docker Image
    ↓
No Docker Hub Push
```

This prevents Docker images from feature branches from being published to Docker Hub.

Branch-based publishing is useful in real CI/CD environments because development branches should generally be validated through CI without automatically publishing every build to the container registry.

---

## Task 5 – Status Badge

A GitHub Actions status badge can be added to the `github-actions-practice` repository README.

```markdown
[![Day 45 - Docker Build and Push](https://github.com/ask-vs9/github-actions-practice/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ask-vs9/github-actions-practice/actions/workflows/docker-publish.yml)
```

The badge provides a quick indication of whether the Day 45 Docker CI/CD workflow is passing.

---

## Task 6 – Pull and Run the Published Image

After the Docker image is published to Docker Hub, it can be pulled and executed from another machine.

### Pull the Image

```bash
docker pull ask09/day45-docker-cicd:latest
```

### Run the Image

```bash
docker run --rm ask09/day45-docker-cicd:latest
```

Expected output:

```text
Test passed
```

This verifies the complete flow from GitHub Actions to Docker Hub and finally to a running Docker container.

---

## Complete CI/CD Journey

The complete Day 45 flow is:

```text
Developer
    |
    | git push
    ↓
GitHub Repository
    |
    ↓
GitHub Actions
    |
    ├── Checkout Code
    |
    ├── Setup Docker Buildx
    |
    ├── Generate Short SHA
    |
    ├── Build Docker Image
    |
    ├── Login to Docker Hub
    |
    ├── Tag Image
    |
    └── Push Image
            |
            ↓
        Docker Hub
            |
            | docker pull
            ↓
      Docker Image
            |
            | docker run
            ↓
      Running Container
            |
            ↓
       Test passed
```

---

## Why Use Commit SHA Tags?

The `latest` tag always represents the latest published image.

The SHA-based tag provides traceability between the Docker image and the Git commit that produced it.

For example:

```text
ask09/day45-docker-cicd:sha-564e5bd
```

This makes it easier to identify which version of the source code produced a particular Docker image.

It is also useful for debugging and rollback scenarios.

---

## Security – Docker Hub Credentials

Docker Hub credentials should never be hardcoded inside the GitHub Actions workflow.

### Avoid

```yaml
username: ask09
password: my-password
```

### Use GitHub Secrets

```yaml
username: ${{ secrets.DOCKER_USERNAME }}
password: ${{ secrets.DOCKER_TOKEN }}
```

Using GitHub Secrets keeps sensitive credentials outside the workflow source code.

---

## Key Takeaways

✔️ GitHub Actions can automatically build Docker images.

✔️ Docker Buildx can be used for Docker builds inside GitHub Actions.

✔️ Docker Hub credentials should be stored securely using GitHub Secrets.

✔️ Docker images can be automatically published to Docker Hub.

✔️ The `latest` tag represents the latest published image.

✔️ Commit SHA tags provide Docker image traceability.

✔️ Docker publishing can be restricted to the `main` branch.

✔️ Feature branches can still run the Docker build without publishing images.

✔️ Docker images can be pulled from Docker Hub and executed on another machine.

✔️ CI/CD eliminates repetitive manual Docker build and push operations.

✔️ Container registries provide centralized storage for Docker images.

---

## Workflows Created

```text
.github/workflows/docker-publish.yml
```

---

## Files Created

```text
Dockerfile
```

The existing:

```text
test_script.py
```

was used as the application executed inside the Docker container.

---

## Docker Commands Used

### Build Image

```bash
docker build -t day45-docker-cicd .
```

### Run Local Image

```bash
docker run --rm day45-docker-cicd
```

### Pull Published Image

```bash
docker pull ask09/day45-docker-cicd:latest
```

### Run Published Image

```bash
docker run --rm ask09/day45-docker-cicd:latest
```

---

## Repositories

### GitHub Actions Practice

https://github.com/ask-vs9/github-actions-practice

### 90DaysOfDevOps

https://github.com/ask-vs9/90DaysOfDevOps

### Docker Hub

https://hub.docker.com/r/ask09/day45-docker-cicd

---

## Day 45 Summary

Day 45 provided hands-on experience building a complete Docker CI/CD pipeline using GitHub Actions.

The workflow automatically builds the Docker image, creates versioned tags, authenticates with Docker Hub using GitHub Secrets, and publishes the image from the `main` branch.

The published Docker image can then be pulled from Docker Hub and executed as a container.

This hands-on implementation helped strengthen my understanding of:

* Docker
* GitHub Actions
* Docker Buildx
* Docker Hub
* GitHub Secrets
* Docker image tagging
* CI/CD automation
* Container registries
* Branch-based publishing
* Docker image versioning

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
