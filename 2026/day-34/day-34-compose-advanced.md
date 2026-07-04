# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Objective
Learn to build a production-like multi-container application using Docker Compose by integrating a web application, PostgreSQL database, and Redis cache.

---

# Task 1: Build Your Own App Stack ✅

### Components Used
- Python Flask (Web Application)
- PostgreSQL (Database)
- Redis (Cache)

### Files Created
```
day-34/
├── app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── docker-compose.yml
└── day-34-compose-advanced.md
```

### Result
- Successfully created a three-service application stack.
- The Flask application was built using a custom Dockerfile.
- PostgreSQL and Redis containers started successfully.
- Verified the application by opening:

```
http://<EC2-Public-IP>:5000
```

Output:

```
Hello from Flask + PostgreSQL + Redis!
```

---

# Task 2: depends_on & Healthchecks ✅

### Configuration
- Added `depends_on` so the web service waits for PostgreSQL.
- Added a PostgreSQL healthcheck using `pg_isready`.

Example:

```yaml
depends_on:
  postgres:
    condition: service_healthy

healthcheck:
  test: ["CMD-SHELL", "pg_isready -U admin -d mydb"]
  interval: 5s
  timeout: 5s
  retries: 5
```

### Result
- Docker waited until PostgreSQL became healthy before starting the Flask application.
- Verified that the application started only after the database was ready.

---

# Task 3: Restart Policies ✅

### Restart Policy Used

```yaml
restart: always
```

### Testing
- Started all containers using Docker Compose.
- Manually killed the PostgreSQL container.

Command:

```bash
docker kill day-34-postgres-1
```

### Observation
- Docker automatically restarted the PostgreSQL container because of the `restart: always` policy.

### Difference Between Restart Policies

| Restart Policy | Description |
|---------------|-------------|
| `always` | Restarts the container whenever it stops, including after Docker daemon restarts. |
| `on-failure` | Restarts the container only if it exits with a non-zero exit code (application failure). |

---

# Task 4: Custom Dockerfiles in Compose ✅

### Configuration

Used:

```yaml
build: ./app
```

instead of pulling a pre-built image.

### Code Change

Modified the Flask application response:

Before:

```python
return "Hello from Flask + PostgreSQL + Redis!"
```

After:

```python
return "Hello Day 34 Docker Compose!"
```

### Rebuild Command

```bash
docker compose up --build
```

### Result
- Docker rebuilt the image.
- The updated application was successfully deployed.

---

# Task 5: Named Networks & Volumes ✅

### Network

Created a custom network:

```yaml
networks:
  app-network:
```

Verified using:

```bash
docker network ls
```

---

### Volume

Created a named volume:

```yaml
volumes:
  postgres-data:
```

Verified using:

```bash
docker volume ls
```

The volume ensures PostgreSQL data remains persistent even if the container is removed.

---

### Labels

Added labels for better organization.

Example:

```yaml
labels:
  project: "day34"
```

---

# Task 6: Scaling (Bonus) ✅

### Command Used

```bash
docker compose up --scale web=3
```

### Observation

Docker attempted to create three web containers.

However, only one container could bind to port **5000** because the host port cannot be shared by multiple containers.

### Why Doesn't Simple Scaling Work?

- Each container tries to expose the same host port (`5000`).
- Only one container can bind to a specific host port.
- Additional containers fail to map the same port.

### Production Solution

In production, a Load Balancer or Reverse Proxy (such as Nginx or Traefik) distributes incoming traffic across multiple application containers instead of exposing each container directly.

---

# Commands Used

```bash
docker compose up --build

docker compose down

docker compose down -v

docker ps

docker logs

docker network ls

docker volume ls

docker kill day-34-postgres-1

docker compose up --scale web=3
```

---

# Learning Outcome

After completing Day 34, I learned:

- Creating multi-container applications using Docker Compose.
- Building Docker images using a custom Dockerfile.
- Managing service dependencies with `depends_on`.
- Using healthchecks to ensure services are ready before startup.
- Configuring restart policies.
- Creating custom Docker networks and persistent volumes.
- Organizing services using labels.
- Understanding the limitations of scaling containers with fixed port mappings.

---

# Conclusion

Successfully deployed a production-style multi-container application using Docker Compose with Flask, PostgreSQL, and Redis. Gained hands-on experience with healthchecks, restart policies, custom Dockerfiles, named networks, persistent volumes, and container scaling concepts that are commonly used in real-world DevOps environments.
