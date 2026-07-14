# Day 41 – Triggers & Matrix Builds

## Objective

The goal of today's task was to understand different ways to trigger GitHub Actions workflows and learn how Matrix Builds execute the same workflow across multiple environments in parallel.

---

# Task 1 – Pull Request Trigger

Created a workflow file:

```text
.github/workflows/pr-check.yml
```

This workflow automatically runs whenever a Pull Request is opened, synchronized, or reopened against the **main** branch.

## Workflow YAML

```yaml
name: Pull Request Check

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
      - reopened

jobs:
  pr-check:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Print PR Branch
        run: |
          echo "PR check running for branch: ${{ github.head_ref }}"
```

### Result

- Created a feature branch.
- Pushed changes to GitHub.
- Opened a Pull Request.
- Verified that the workflow executed automatically.
- Successfully merged the Pull Request.

---

# Task 2 – Scheduled Trigger

Created a scheduled workflow.

Workflow file:

```text
.github/workflows/schedule.yml
```

## Workflow YAML

```yaml
name: Scheduled Workflow

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  schedule-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Scheduled Time
        run: echo "Scheduled workflow executed."
```

## Cron Expressions

Every day at midnight (UTC)

```text
0 0 * * *
```

Every Monday at 9:00 AM (UTC)

```text
0 9 * * 1
```

### Result

Successfully created a scheduled workflow and learned how GitHub Actions uses cron expressions for automatic execution.

---

# Task 3 – Manual Trigger

Created a manually triggered workflow.

Workflow file:

```text
.github/workflows/manual.yml
```

## Workflow YAML

```yaml
name: Manual Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Deployment Environment"
        required: true
        default: "staging"

jobs:
  manual-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Selected Environment
        run: |
          echo "Environment: ${{ github.event.inputs.environment }}"
```

### Result

- Triggered the workflow manually from the GitHub Actions page.
- Selected the deployment environment.
- Verified that the selected input value was printed in the workflow logs.

---

# Task 4 – Matrix Builds

Created a Matrix Build workflow.

Workflow file:

```text
.github/workflows/matrix.yml
```

## Workflow YAML

```yaml
name: Matrix Build

on:
  push:

jobs:
  matrix-job:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os:
          - ubuntu-latest
          - windows-latest

        python-version:
          - "3.10"
          - "3.11"
          - "3.12"

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python Version
        run: python --version
```

### Result

Successfully executed the workflow across:

- Ubuntu + Python 3.10
- Ubuntu + Python 3.11
- Ubuntu + Python 3.12
- Windows + Python 3.10
- Windows + Python 3.11
- Windows + Python 3.12

Total jobs executed:

```text
2 Operating Systems × 3 Python Versions = 6 Jobs
```

This demonstrated how Matrix Builds execute multiple jobs in parallel across different operating systems and Python versions.

---

# Task 5 – Exclude & Fail-Fast

Updated the Matrix Build workflow to exclude one matrix combination and disable fail-fast.

## Updated Strategy

```yaml
strategy:
  fail-fast: false

  matrix:
    os:
      - ubuntu-latest
      - windows-latest

    python-version:
      - "3.10"
      - "3.11"
      - "3.12"

    exclude:
      - os: windows-latest
        python-version: "3.10"
```

Added an intentional failure:

```yaml
- name: Fail Ubuntu Python 3.11
  if: matrix.os == 'ubuntu-latest' && matrix.python-version == '3.11'
  run: |
    echo "Intentional Failure"
    exit 1
```

### Observation

**fail-fast: true (Default)**

- Stops all remaining matrix jobs when the first job fails.
- Saves execution time and compute resources.

**fail-fast: false**

- Continues running all remaining jobs even if one job fails.
- Useful when validating applications across multiple environments.

---

# What I Learned

- Learned how Pull Request triggers work in GitHub Actions.
- Learned how to schedule workflows using Cron expressions.
- Created and executed a manual workflow using `workflow_dispatch`.
- Used workflow inputs to pass deployment environments.
- Built Matrix workflows to run jobs across multiple operating systems and Python versions.
- Learned how Matrix Builds execute jobs in parallel.
- Understood how to exclude specific matrix combinations.
- Learned the difference between `fail-fast: true` and `fail-fast: false`.
- Improved my ability to read workflow logs and troubleshoot GitHub Actions pipelines.

---

# Outcome

Successfully implemented and tested multiple GitHub Actions workflow triggers, including Pull Request, Scheduled, Manual, and Matrix workflows.

This exercise strengthened my understanding of GitHub Actions automation, workflow triggers, matrix strategies, parallel job execution, and debugging CI/CD pipelines. These concepts are fundamental for building reliable and scalable DevOps workflows.
