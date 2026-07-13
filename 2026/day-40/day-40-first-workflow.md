# Day 40 – My First GitHub Actions Workflow

## Objective

The goal of today's task was to create my first GitHub Actions workflow and understand the basic building blocks of a CI/CD pipeline.

---

# Task 1 – Repository Setup

Created a new public GitHub repository:

**Repository Name:**

```
github-actions-practice
```

Created the required GitHub Actions directory structure:

```
.github/
└── workflows/
```

---

# Task 2 – Hello Workflow

Created a workflow file named:

```
.github/workflows/hello.yml
```

The workflow triggers automatically on every **push** and performs a simple task of printing a message.

## Workflow

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
        run: |
          echo "Hello from GitHub Actions!"

      - name: Print Current Date and Time
        run: |
          date

      - name: Print Branch Name
        run: |
          echo "Branch Name: ${{ github.ref_name }}"

      - name: List Repository Files
        run: |
          ls -la

      - name: Print Runner Operating System
        run: |
          echo "Runner OS: $RUNNER_OS"
```

---

# Task 3 – Understanding the Workflow

## `name`

Provides a friendly name for the workflow that appears in the GitHub Actions tab.

---

## `on`

Defines the event that triggers the workflow.

```yaml
on:
  push:
```

The workflow starts automatically whenever code is pushed to the repository.

---

## `jobs`

A workflow can contain one or more jobs.

In this project, there is one job named:

```
greet
```

---

## `runs-on`

Specifies the operating system used by the GitHub-hosted runner.

```yaml
runs-on: ubuntu-latest
```

---

## `steps`

A job is divided into multiple steps.

Each step performs one specific task.

---

## `uses`

Runs an existing GitHub Action.

```yaml
uses: actions/checkout@v4
```

This action checks out the repository so the runner can access the project files.

---

## `run`

Executes Linux shell commands on the GitHub runner.

Example:

```yaml
run: |
  echo "Hello from GitHub Actions!"
```

---

# Task 4 – Added More Steps

The workflow was enhanced by adding additional steps.

### Added the following:

- Printed a Hello message
- Printed the current date and time
- Printed the branch name
- Listed all repository files
- Printed the runner operating system

This helped me understand how GitHub Actions can execute Linux commands and use GitHub context variables.

---

# Task 5 – Breaking and Fixing the Workflow

To understand how GitHub Actions handles failures, I intentionally added a failing step.

```yaml
- name: Fail the Workflow
  run: |
    exit 1
```

The workflow failed with the following message:

```
Process completed with exit code 1.
```

After reading the workflow logs, I removed the failing step, committed the changes, pushed the updated workflow, and confirmed that the workflow completed successfully.

This exercise helped me understand how to debug failed GitHub Actions workflows.

---

# What I Learned

- How to create my first GitHub Actions workflow.
- How GitHub Actions automatically triggers workflows on every push.
- The purpose of `on`, `jobs`, `runs-on`, `steps`, `uses`, and `run`.
- How to execute Linux commands using GitHub Actions.
- How to use GitHub context variables like `${{ github.ref_name }}`.
- The importance of correct YAML syntax and indentation.
- How to read GitHub Actions logs and troubleshoot workflow failures.

---

# Screenshots

The following screenshots were captured during the lab:

- Successful GitHub Actions workflow
- Workflow after adding additional steps
- Failed workflow showing `Process completed with exit code 1`
- Final successful workflow after fixing the issue

---

# Outcome

Successfully created, executed, updated, intentionally broke, debugged, and fixed my first GitHub Actions workflow.

This exercise provided a solid foundation for understanding CI/CD pipelines using GitHub Actions.
