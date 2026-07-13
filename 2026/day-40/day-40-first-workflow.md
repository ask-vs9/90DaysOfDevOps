# Day 40 – My First GitHub Actions Workflow

# Task 3 – Understanding the Workflow Anatomy

## Workflow File

```yaml
name: My First GitHub Actions Workflow

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Print Hello Message
        run: echo "Hello from GitHub Actions!"
```

---

# What Each Key Does

## name

The `name` gives a friendly name to the workflow. It is displayed in the GitHub Actions tab.

**Example:**

```yaml
name: My First GitHub Actions Workflow
```

---

## on

The `on` keyword defines the event that triggers the workflow.

In this workflow:

```yaml
on:
  push:
```

The workflow starts automatically whenever code is pushed to the repository.

---

## jobs

A workflow can contain one or more jobs.

Each job performs a specific task.

In this workflow:

```yaml
jobs:
  greet:
```

The workflow contains one job called **greet**.

---

## runs-on

This specifies which machine will execute the job.

```yaml
runs-on: ubuntu-latest
```

GitHub creates a temporary Ubuntu virtual machine and runs all the steps on it.

---

## steps

A job is divided into multiple steps.

Each step performs one task.

```yaml
steps:
```

In our workflow, we have two steps.

---

## uses

The `uses` keyword tells GitHub to use an existing action.

```yaml
uses: actions/checkout@v4
```

This action downloads the repository code onto the GitHub runner so the workflow can access the project files.

---

## run

The `run` keyword executes shell commands on the runner.

Example:

```yaml
run: echo "Hello from GitHub Actions!"
```

This prints a message in the workflow logs.

---

## Step Name

Each step can have a descriptive name.

Example:

```yaml
name: Checkout Repository
```

The step name makes the workflow easier to read in the GitHub Actions interface.

---

# Key Learnings

- A workflow starts when a defined event occurs.
- A workflow contains one or more jobs.
- Each job runs on a GitHub-hosted runner.
- Jobs contain multiple steps.
- The `uses` keyword executes reusable GitHub Actions.
- The `run` keyword executes shell commands.
