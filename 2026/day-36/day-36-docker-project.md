# Day 36 – Dockerize a Full Application

## Objective

The goal of this project was to Dockerize a complete Node.js application with MongoDB using Docker best practices. The application was containerized using a multi-stage Dockerfile and orchestrated with Docker Compose.

---

# Task 1 – Application Selection

## Application Chosen

Node.js Express application with MongoDB.

### Why I Chose This Project

- Simple to understand and deploy.
- Demonstrates a real-world multi-container application.
- Covers Docker Compose, networking, volumes, and environment variables.
- Useful for learning Docker deployment workflows.

---

# Task 2 – Dockerfile

## Dockerfile

```dockerfile
# Stage 1 - Build
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Stage 2 - Production
FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["npm", "start"]
```

### Dockerfile Explanation

- **FROM node:22-alpine AS builder** – Uses a lightweight Alpine-based Node.js image for the build stage.
- **WORKDIR /app** – Sets the working directory inside the container.
- **COPY package*.json ./** – Copies dependency files.
- **RUN npm install** – Installs project dependencies.
- **COPY . .** – Copies the application source code.
- **COPY --from=builder /app .** – Copies only the required application files into the final image.
- **RUN addgroup...adduser...** – Creates a non-root user for improved security.
- **USER appuser** – Runs the application as a non-root user.
- **EXPOSE 3000** – Exposes port 3000.
- **CMD ["npm", "start"]** – Starts the Node.js application.

---

# Task 3 – Docker Compose

## Services

- Node.js Application
- MongoDB Database

## Features Implemented

- Docker Compose
- Custom bridge network
- Named Docker volume
- Environment variables using `.env`
- MongoDB health check
- Persistent database storage

### Start the Application

```bash
docker compose up -d
```

### Stop the Application

```bash
docker compose down
```

---

# Task 4 – Docker Hub

## Docker Image

The application image was tagged and pushed to Docker Hub.

### Commands Used

```bash
docker tag node-mongodb-app ask09/node-mongodb-app:v1
docker tag node-mongodb-app ask09/node-mongodb-app:latest

docker push ask09/node-mongodb-app:v1
docker push ask09/node-mongodb-app:latest
```

Docker Hub Repository:

https://hub.docker.com/r/ask09/node-mongodb-app

---

# Task 5 – Fresh Deployment Test

To verify the deployment process:

1. Removed local application images.
2. Pulled the image from Docker Hub.
3. Started the application using Docker Compose.
4. Verified the application was accessible.
5. Confirmed MongoDB connectivity.

The application worked successfully after a fresh deployment.

---

# Challenges Faced

### MongoDB Connection Error

Initially received:

```
MongooseServerSelectionError: getaddrinfo EAI_AGAIN mongodb
```

### Resolution

This occurred because MongoDB was not running outside Docker Compose.

After starting the MongoDB service using Docker Compose, the application connected successfully.

---

# Final Image Information

| Image | Size |
|--------|------|
| node-mongodb-app | ~230 MB |

---

# Project Structure

```
day-36/
├── app/
│   ├── app.js
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   ├── .dockerignore
│   ├── .env
│   └── README.md
├── docker-compose.yml
└── day-36-docker-project.md
```

---

# Learning Outcome

Through this project, I learned how to:

- Dockerize a complete Node.js application.
- Use multi-stage Docker builds.
- Build lightweight and secure Docker images.
- Create Docker Compose configurations.
- Connect application and database containers.
- Use Docker volumes for persistent storage.
- Configure environment variables.
- Implement Docker health checks.
- Publish Docker images to Docker Hub.
- Verify deployments from a clean environment.

---

# Conclusion

Successfully Dockerized a complete Node.js and MongoDB application, orchestrated it using Docker Compose, and published the application image to Docker Hub following Docker best practices.
