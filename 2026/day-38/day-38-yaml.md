# Day 38 – YAML Basics

## Objective

The goal of this lab was to learn the basics of YAML syntax, understand how YAML files are structured, and practice writing valid YAML files that can be used in DevOps tools such as GitHub Actions, Kubernetes, Ansible, and Docker Compose.

---

# Task 1 – Key-Value Pairs

## person.yaml

```yaml
name: Avinash S Kumar
role: AWS Cloud & DevOps Engineer
experience_years: 3
learning: true
```

### What I Learned

- YAML stores data using **key-value pairs**.
- A colon (`:`) separates the key and value.
- Boolean values are written as `true` or `false` without quotes.

---

# Task 2 – Lists

## Updated person.yaml

```yaml
name: Avinash S Kumar
role: AWS Cloud & DevOps Engineer
experience_years: 3
learning: true

tools:
  - AWS
  - Docker
  - Kubernetes
  - Jenkins
  - Terraform

hobbies: [Playing Guitar, Learning DevOps, Reading Tech Blogs]
```

### Two Ways to Write Lists in YAML

### 1. Block Style List

```yaml
tools:
  - AWS
  - Docker
  - Kubernetes
```

### 2. Inline Style List

```yaml
hobbies: [Playing Guitar, Learning DevOps, Reading Tech Blogs]
```

---

# Task 3 – Nested Objects

## server.yaml

```yaml
---
server:
  name: web-server
  ip: 192.168.1.10
  port: 80

database:
  host: localhost
  name: employee_db
  credentials:
    user: admin
    password: admin123
```

### What I Learned

- Nested objects are created using indentation.
- YAML only supports **spaces** for indentation.
- Using tabs causes validation errors.

---

# Task 4 – Multi-line Strings

## Pipe Style (`|`)

```yaml
startup_script_pipe: |
  #!/bin/bash
  echo "Starting Application"
  sudo systemctl start nginx
  echo "Application Started"
```

The **pipe (`|`)** preserves line breaks exactly as written.

It is commonly used for:

- Shell scripts
- Bash commands
- Kubernetes ConfigMaps
- Ansible playbooks

---

## Fold Style (`>`)

```yaml
startup_script_fold: >
  This startup script installs all
  required packages before
  starting the application.
```

The **greater-than (`>`)** folds multiple lines into a single line.

It is commonly used for:

- Long descriptions
- Documentation
- Notes

---

# Task 5 – YAML Validation

## Validation Tool

I installed **yamllint** to validate my YAML files.

Commands used:

```bash
yamllint person.yaml
yamllint server.yaml
```

### Error Observed

When I intentionally removed the indentation, yamllint returned:

```
syntax error: mapping values are not allowed here
```

After correcting the indentation using spaces, the YAML validated successfully.

---

# Task 6 – Spot the Difference

## Correct YAML

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

## Incorrect YAML

```yaml
name: devops
tools:
- docker
  - kubernetes
```

### What is Wrong?

The second example has incorrect indentation.

YAML uses spaces to determine the structure of the data. Incorrect indentation can result in syntax or validation errors. Consistent indentation (commonly two spaces) should always be used.

---

# Key Learnings

1. YAML uses spaces for indentation and does not support tabs.
2. Lists can be written using either block style or inline style.
3. Multi-line strings can be written using `|` to preserve line breaks or `>` to fold lines into a single line.

---

# Files Created

- person.yaml
- server.yaml
- day-38-yaml.md

---

# Conclusion

This lab helped me understand the fundamentals of YAML, including key-value pairs, lists, nested objects, multi-line strings, indentation rules, and validation. These concepts are essential for working with modern DevOps tools such as Docker Compose, Kubernetes, GitHub Actions, and Ansible.
