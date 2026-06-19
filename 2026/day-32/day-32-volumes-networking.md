# Day 32 – Docker Volumes & Networking

## Objective

The goal of this exercise was to understand data persistence using Docker volumes and container communication using Docker networks.

---

## Task 1: The Problem

### Run MySQL Container

```bash
docker run -d --name mysql1 \
-e MYSQL_ROOT_PASSWORD=root123 \
mysql
```

### Create Data

Connected to MySQL and created a database, table, and sample records.

```sql
CREATE DATABASE testdb;
USE testdb;

CREATE TABLE users (
id INT,
name VARCHAR(50)
);

INSERT INTO users VALUES (1,'Avinash');

SELECT * FROM users;
```

### Remove Container

```bash
docker stop mysql1
docker rm mysql1
```

### Create New Container

```bash
docker run -d --name mysql2 \
-e MYSQL_ROOT_PASSWORD=root123 \
mysql
```

### Observation

The database and table were no longer available.

### Why?

Containers are ephemeral. Without persistent storage, all data stored inside the container filesystem is lost when the container is removed.

---

## Task 2: Named Volumes

### Create Volume

```bash
docker volume create mysql-data
```

### Verify Volume

```bash
docker volume ls
```

### Run MySQL with Volume

```bash
docker run -d \
--name mysql-volume \
-e MYSQL_ROOT_PASSWORD=root123 \
-v mysql-data:/var/lib/mysql \
mysql
```

### Create Data

```sql
CREATE DATABASE testdb;
```

### Remove Container

```bash
docker stop mysql-volume
docker rm mysql-volume
```

### Create New Container with Same Volume

```bash
docker run -d \
--name mysql-volume-new \
-e MYSQL_ROOT_PASSWORD=root123 \
-v mysql-data:/var/lib/mysql \
mysql
```

### Observation

The database still existed.

### Verify

```bash
docker volume inspect mysql-data
```

### Conclusion

Named volumes persist data independently of containers.

---

## Task 3: Bind Mounts

### Create Host Directory

```bash
mkdir website
cd website
```

### Create index.html

```html
<h1>Hello from Docker Bind Mount</h1>
```

### Run Nginx with Bind Mount

```bash
docker run -d \
--name nginx-bind \
-p 8080:80 \
-v $(pwd):/usr/share/nginx/html \
nginx
```

### Verify

Opened:

```text
http://localhost:8080
```

The custom page was displayed.

### Modify index.html

Changed the content and refreshed the browser.

### Observation

Changes appeared immediately without rebuilding the container.

### Named Volume vs Bind Mount

| Named Volume          | Bind Mount               |
| --------------------- | ------------------------ |
| Managed by Docker     | Managed by Host OS       |
| Stored in Docker area | Stored in Host Directory |
| Better for databases  | Better for development   |
| Portable              | Host-path dependent      |

---

## Task 4: Docker Networking Basics

### List Networks

```bash
docker network ls
```

### Inspect Bridge Network

```bash
docker network inspect bridge
```

### Run Containers

```bash
docker run -dit --name ubuntu1 ubuntu
docker run -dit --name ubuntu2 ubuntu
```

### Test Communication by IP

Found IP address using:

```bash
docker inspect ubuntu1
```

Ping by IP:

```bash
docker exec -it ubuntu2 ping <IP_ADDRESS>
```

Result:

```text
Successful
```

### Test Communication by Name

```bash
docker exec -it ubuntu2 ping ubuntu1
```

Result:

```text
Failed
```

### Conclusion

Containers on the default bridge network can communicate using IP addresses but not by container names.

---

## Task 5: Custom Networks

### Create Network

```bash
docker network create my-app-net
```

### Run Containers on Custom Network

```bash
docker run -dit \
--name app1 \
--network my-app-net \
ubuntu
```

```bash
docker run -dit \
--name app2 \
--network my-app-net \
ubuntu
```

### Ping by Name

```bash
docker exec -it app2 ping app1
```

Result:

```text
Successful
```

### Why?

Custom bridge networks provide built-in DNS resolution, allowing containers to communicate using container names.

---

## Task 6: Put It Together

### Create Network

```bash
docker network create app-network
```

### Create Volume

```bash
docker volume create db-data
```

### Run Database Container

```bash
docker run -d \
--name mysql-db \
--network app-network \
-v db-data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=root123 \
mysql
```

### Run Application Container

```bash
docker run -dit \
--name app-container \
--network app-network \
ubuntu
```

### Verify Connectivity

```bash
docker exec -it app-container bash
```

Install ping utility:

```bash
apt update
apt install iputils-ping -y
```

Ping database container:

```bash
ping mysql-db
```

Result:

```text
Successful
```

### Conclusion

The application container successfully communicated with the database container using the container name over the custom Docker network.

---

## Commands Learned

```bash
docker volume create
docker volume ls
docker volume inspect
docker network ls
docker network inspect
docker network create
docker exec
docker run -v
docker run --network
```

---

## Key Takeaways

* Containers are ephemeral and lose data when removed.
* Docker volumes provide persistent storage.
* Bind mounts connect host directories to containers.
* Default bridge networks support IP-based communication.
* Custom bridge networks provide DNS-based name resolution.
* Volumes and networking are essential for real-world containerized applications.

## Conclusion

Today I learned how Docker handles persistent storage using volumes and bind mounts, and how containers communicate using Docker networks. I also built a small multi-container setup with persistent storage and verified communication between containers using container names.

