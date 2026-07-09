# Docker Cheat Sheet

## Container Commands

| Command | Description |
|---------|-------------|
| `docker run image` | Run a new container |
| `docker run -it ubuntu bash` | Run a container in interactive mode |
| `docker run -d nginx` | Run a container in detached mode |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker stop <container>` | Stop a running container |
| `docker start <container>` | Start a stopped container |
| `docker restart <container>` | Restart a container |
| `docker rm <container>` | Remove a container |
| `docker exec -it <container> bash` | Open a terminal inside a container |
| `docker logs <container>` | View container logs |

---

## Image Commands

| Command | Description |
|---------|-------------|
| `docker images` | List all Docker images |
| `docker build -t image-name .` | Build an image from a Dockerfile |
| `docker pull nginx` | Download an image from Docker Hub |
| `docker push username/image` | Push an image to Docker Hub |
| `docker tag image username/image:v1` | Tag an image |
| `docker rmi image` | Remove an image |

---

## Volume Commands

| Command | Description |
|---------|-------------|
| `docker volume create volume-name` | Create a volume |
| `docker volume ls` | List all volumes |
| `docker volume inspect volume-name` | Inspect a volume |
| `docker volume rm volume-name` | Remove a volume |

---

## Network Commands

| Command | Description |
|---------|-------------|
| `docker network create network-name` | Create a network |
| `docker network ls` | List all networks |
| `docker network inspect network-name` | Inspect a network |
| `docker network connect network-name container-name` | Connect a container to a network |

---

## Docker Compose Commands

| Command | Description |
|---------|-------------|
| `docker compose up` | Start all services |
| `docker compose up -d` | Start services in detached mode |
| `docker compose down` | Stop and remove containers |
| `docker compose down -v` | Stop containers and remove volumes |
| `docker compose ps` | Show Compose containers |
| `docker compose logs` | View service logs |
| `docker compose build` | Build Compose images |

---

## Cleanup Commands

| Command | Description |
|---------|-------------|
| `docker system df` | Show Docker disk usage |
| `docker system prune -a` | Remove unused Docker resources |
| `docker volume prune` | Remove unused volumes |
| `docker builder prune` | Remove build cache |

---

## Dockerfile Instructions

| Instruction | Purpose |
|------------|---------|
| `FROM` | Defines the base image |
| `WORKDIR` | Sets the working directory |
| `COPY` | Copies files into the image |
| `ADD` | Copies files and can extract archives or download URLs |
| `RUN` | Executes commands during image build |
| `ENV` | Sets environment variables |
| `EXPOSE` | Documents the port the container listens on |
| `CMD` | Specifies the default command to run |
| `ENTRYPOINT` | Defines the main executable for the container |
