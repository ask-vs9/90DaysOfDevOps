# Day 29 – Docker Basics

## Task 1: What is Docker?

### What is a Container and Why Do We Need It?

A container is a lightweight package that contains an application and all of its dependencies required to run consistently across different environments.

Containers are used to:

* Eliminate the "it works on my machine" problem
* Improve application portability
* Reduce resource usage
* Simplify deployment and scaling
* Ensure consistency between development and production environments

### Containers vs Virtual Machines

| Feature             | Containers   | Virtual Machines |
| ------------------- | ------------ | ---------------- |
| Virtualization Type | OS-level     | Hardware-level   |
| Startup Time        | Seconds      | Minutes          |
| Resource Usage      | Lightweight  | Heavy            |
| Guest OS            | Not Required | Required         |
| Size                | MBs          | GBs              |

**Difference:**
Virtual Machines run a complete operating system on virtualized hardware, while containers share the host operating system kernel and package only the application and its dependencies.

### Docker Architecture

Docker architecture consists of the following components:

#### Docker Client

The Docker Client is the command-line interface used to interact with Docker.

#### Docker Daemon

The Docker Daemon (`dockerd`) is a background service responsible for building, running, and managing containers.

#### Docker Images

Docker images are read-only templates used to create containers.

#### Docker Containers

Containers are running instances of Docker images.

#### Docker Registry

A Docker Registry stores Docker images. Docker Hub is the default public registry.

### Docker Architecture Diagram

```text
+------------------+
|  Docker Client   |
+--------+---------+
         |
         v
+------------------+
|  Docker Daemon   |
+--------+---------+
         |
    +----+----+
    |         |
    v         v
 Images   Containers
    |
    v
Docker Hub
(Registry)
```

---

## Task 2: Install Docker

### Verify Docker Installation

Command:

```bash
docker --version
```

Output:

```text
Docker version 29.5.3, build d1c06ef
```

### Run Hello World Container

Command:

```bash
docker run hello-world
```

Result:
Docker downloaded the image from Docker Hub, created a container, executed it, and displayed a success message.

---

## Task 3: Run Real Containers

### Run an Nginx Container

Command:

```bash
docker run -d --name my-nginx -p 8080:80 nginx
```

This starts an Nginx container in detached mode and maps port 8080 on the host to port 80 inside the container.

Access:

```text
http://localhost:8080
```

The Nginx welcome page confirms that the container is running correctly.

### Run an Ubuntu Container in Interactive Mode

Command:

```bash
docker run -it ubuntu bash
```

Commands executed inside the container:

```bash
pwd
ls
cat /etc/os-release
```

This allows interaction with the Ubuntu container as if it were a small Linux machine.

### List Running Containers

```bash
docker ps
```

### List All Containers

```bash
docker ps -a
```

### Stop a Container

```bash
docker stop my-nginx
```

### Remove a Container

```bash
docker rm my-nginx
```

---

## Task 4: Explore Docker Features

### Run a Container in Detached Mode

```bash
docker run -d nginx
```

Detached mode runs the container in the background and immediately returns control to the terminal.

### Give a Container a Custom Name

```bash
docker run -d --name webserver nginx
```

### Map a Port from Container to Host

```bash
docker run -d -p 8080:80 nginx
```

This maps host port 8080 to container port 80.

### Check Logs of a Running Container

```bash
docker logs webserver
```

### Run a Command Inside a Running Container

```bash
docker exec -it webserver bash
```

Example:

```bash
ls /usr/share/nginx/html
```

---

## Commands Learned

```bash
docker --version
docker run hello-world
docker run -d nginx
docker run -it ubuntu bash
docker ps
docker ps -a
docker stop my-nginx
docker rm my-nginx
docker logs webserver
docker exec -it webserver bash
```

---

## Key Takeaways

* Docker packages applications and dependencies into containers.
* Containers are lightweight and portable.
* Docker images are used to create containers.
* Docker Hub is a registry for storing and sharing images.
* Detached mode runs containers in the background.
* Port mapping allows access to services running inside containers.
* Docker logs and exec commands help monitor and troubleshoot containers.

## Conclusion

Today I learned the fundamentals of Docker and containerization. I explored Docker architecture, verified Docker installation, ran containers using Docker Hub images, managed running containers, and practiced essential Docker commands used in modern DevOps environments.

