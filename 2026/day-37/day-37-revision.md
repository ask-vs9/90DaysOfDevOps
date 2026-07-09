# Day 37 – Docker Revision

## Self Assessment Checklist

- [x] Run a container from Docker Hub (interactive + detached) — Can Do
- [x] List, stop, remove containers and images — Can Do
- [x] Explain image layers and how caching works — Can Do
- [x] Write a Dockerfile using FROM, RUN, COPY, WORKDIR and CMD — Can Do
- [x] Explain CMD vs ENTRYPOINT — Can Do
- [x] Build and tag a custom image — Can Do
- [x] Create and use named volumes — Can Do
- [x] Use bind mounts — Can Do
- [x] Create custom networks and connect containers — Can Do
- [x] Write a docker-compose.yml for a multi-container application — Can Do
- [x] Use environment variables and .env files in Compose — Can Do
- [x] Write a multi-stage Dockerfile — Can Do
- [x] Push images to Docker Hub — Can Do
- [x] Use healthchecks and depends_on — Can Do


# Quick Fire Questions

## 1. What is the difference between an image and a container?

A Docker image is a template that contains everything required to run an application. A container is the running instance of that image.

---

## 2. What happens to data inside a container when you remove it?

Any data stored inside the container is removed when the container is deleted. To keep data permanently, Docker Volumes or Bind Mounts should be used.

---

## 3. How do two containers on the same custom network communicate?

Containers communicate using their container or service names. Docker automatically provides DNS resolution within the same custom network.

Example:

mongodb:27017

---

## 4. What does docker compose down -v do differently?

docker compose down removes containers and networks.

docker compose down -v removes containers, networks, and Docker volumes.

---

## 5. Why are multi-stage builds useful?

Multi-stage builds create smaller and more secure images by copying only the required application files into the final image.

---

## 6. Difference between COPY and ADD?

COPY only copies files.

ADD can also extract compressed files and download files from URLs.

Generally COPY is preferred.

---

## 7. What does -p 8080:80 mean?

It maps port 8080 on the host machine to port 80 inside the container.

Host:8080 → Container:80

---

## 8. How do you check Docker disk usage?

```bash
docker system df
```
