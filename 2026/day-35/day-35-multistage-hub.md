# Day 35 – Multi-Stage Builds & Docker Hub

## Objective

Learned how to create optimized Docker images using multi-stage builds and publish them to Docker Hub.

---

# Task 1 – Single Stage Build

### Dockerfile

```dockerfile
FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Build Command

```bash
docker build -f Dockerfile.single -t node-single .
```

### Image Size

| Image | Size |
|--------|------|
| node-single | **1.63 GB** |

---

# Task 2 – Multi-Stage Build

### Dockerfile

```dockerfile
FROM node:22 AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3000

CMD ["npm", "start"]
```

### Build Command

```bash
docker build -f Dockerfile.multi -t node-multi .
```

### Image Size

| Image | Size |
|--------|------|
| node-single | **1.63 GB** |
| node-multi | **230 MB** |

### Comparison

The multi-stage image is much smaller because:
- Only the required application files are copied.
- Build dependencies are excluded.
- A lightweight Alpine runtime image is used.
- Smaller images are faster to download and more secure.

---

# Task 3 – Push to Docker Hub

### Login

```bash
docker login
```

### Tag Image

```bash
docker tag node-multi ask09/day35-node-app:v1
docker tag node-multi ask09/day35-node-app:latest
```

### Push Image

```bash
docker push ask09/day35-node-app:v1
docker push ask09/day35-node-app:latest
```

### Verify

```bash
docker pull ask09/day35-node-app:latest
```

### Docker Hub Repository

https://hub.docker.com/r/ask09/day35-node-app

---

# Task 4 – Docker Hub Repository

### Repository Description

> Node.js application demonstrating Docker Multi-Stage Builds and Docker Hub image publishing.

### Available Tags

- latest
- v1

### Difference Between Tags

- **latest** always points to the most recent image.
- **v1** points to a specific version of the application.
- Version tags make deployments consistent and easier to roll back.

---

# Task 5 – Image Best Practices

### Best Practices Applied

- Used a lightweight base image (`node:22-alpine`).
- Used a non-root user.
- Combined `RUN` commands to reduce image layers.
- Used a specific base image tag instead of `latest`.
- Added a `.dockerignore` file.

### Benefits

- Smaller image size
- Improved security
- Faster downloads
- Better performance
- Easier maintenance

---

# Learning Outcome

In this lab, I learned how to:

- Build Docker images using a single-stage Dockerfile.
- Optimize Docker images with multi-stage builds.
- Compare image sizes before and after optimization.
- Push Docker images to Docker Hub.
- Manage Docker image tags (`latest` and version tags).
- Apply Docker image best practices for production-ready containers.
