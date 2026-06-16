# Day 30 – Docker Images & Container Lifecycle

## Task 1: Docker Images

### Pull Docker Images

Pulled the following images from Docker Hub:

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
```

### List All Images

```bash
docker images
```

This command displays all locally available Docker images along with their repository, tag, image ID, creation date, and size.

### Ubuntu vs Alpine

| Image  | Approximate Size |
| ------ | ---------------- |
| Ubuntu | ~80 MB           |
| Alpine | ~8 MB            |

**Why is Alpine smaller?**

Alpine Linux is designed to be lightweight and minimal. It contains only the essential packages required to run Linux applications. Ubuntu includes many additional utilities, libraries, and tools, making it significantly larger.

### Inspect an Image

```bash
docker inspect nginx
```

Information available from image inspection:

* Image ID
* Creation date
* Architecture
* Operating system
* Environment variables
* Exposed ports
* Entrypoint
* Layers

### Remove an Image

```bash
docker rmi alpine
```

This removes the Alpine image if no containers are using it.

---

## Task 2: Image Layers

### View Image History

```bash
docker image history nginx
```

### What Are Layers?

Docker images are built using multiple read-only layers.

Each instruction in a Dockerfile creates a new layer.

Example:

```text
Base OS Layer
      ↓
Package Installation Layer
      ↓
Configuration Layer
      ↓
Application Layer
```

### Why Docker Uses Layers

* Faster image builds
* Reduced storage usage
* Efficient image sharing
* Improved caching
* Faster downloads

### Why Some Layers Show 0B

Some layers only store metadata changes such as:

* Environment variables
* Labels
* Commands

Since no actual files are added, the layer size appears as 0B.

---

## Task 3: Container Lifecycle

### Create a Container Without Starting

```bash
docker create --name lifecycle-demo nginx
```

### Start the Container

```bash
docker start lifecycle-demo
```

### Pause the Container

```bash
docker pause lifecycle-demo
```

Check status:

```bash
docker ps -a
```

### Unpause the Container

```bash
docker unpause lifecycle-demo
```

### Stop the Container

```bash
docker stop lifecycle-demo
```

### Restart the Container

```bash
docker restart lifecycle-demo
```

### Kill the Container

```bash
docker kill lifecycle-demo
```

### Remove the Container

```bash
docker rm lifecycle-demo
```

### Container States Observed

```text
Created
   ↓
Running
   ↓
Paused
   ↓
Running
   ↓
Exited
   ↓
Running
   ↓
Killed
   ↓
Removed
```

---

## Task 4: Working with Running Containers

### Run Nginx in Detached Mode

```bash
docker run -d --name webserver -p 8080:80 nginx
```

### View Logs

```bash
docker logs webserver
```

### Follow Logs in Real Time

```bash
docker logs -f webserver
```

Press:

```text
Ctrl + C
```

to exit log streaming.

### Enter the Running Container

```bash
docker exec -it webserver bash
```

Explore the filesystem:

```bash
pwd
ls
cd /usr/share/nginx/html
ls
```

### Run a Single Command Inside the Container

```bash
docker exec webserver ls /usr/share/nginx/html
```

### Inspect the Container

```bash
docker inspect webserver
```

Useful information found:

* Container IP Address
* Port Mappings
* Network Configuration
* Mount Points
* Container State

---

## Task 5: Cleanup

### Stop All Running Containers

```bash
docker stop $(docker ps -q)
```

### Remove All Stopped Containers

```bash
docker container prune
```

### Remove Unused Images

```bash
docker image prune -a
```

### Check Docker Disk Usage

```bash
docker system df
```

### Remove Unused Docker Resources

```bash
docker system prune
```

---

## Commands Learned

```bash
docker pull
docker images
docker inspect
docker image history
docker create
docker start
docker pause
docker unpause
docker stop
docker restart
docker kill
docker rm
docker logs
docker logs -f
docker exec
docker system df
docker system prune
```

---

## Key Takeaways

* Docker images are templates used to create containers.
* Containers are running instances of images.
* Docker images are made up of multiple layers.
* Layers improve storage efficiency and build performance.
* Containers move through different lifecycle states such as created, running, paused, stopped, and removed.
* Docker provides tools to inspect, manage, and troubleshoot containers.
* Cleanup commands help free disk space and remove unused resources.

## Conclusion

Today I learned how Docker images work, explored image layers and caching, and practiced the complete container lifecycle. I also learned how to inspect images and containers, monitor logs, execute commands inside running containers, and clean up unused Docker resources.

