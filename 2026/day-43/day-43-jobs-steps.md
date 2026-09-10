# Day 43 – Jobs, Steps, Environment Variables & Conditionals

## Overview

Today I learned how to control the flow of GitHub Actions workflows using:

- Multiple jobs
- Job dependencies with `needs:`
- Environment variables
- GitHub context variables
- Job outputs
- Conditional execution
- `continue-on-error`
- Parallel jobs
- Job dependencies

---

# Task 1 – Multi-Job Workflow

Workflow file:

`.github/workflows/multi-job.yml`

The workflow contains three jobs:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build
        run: echo "Building the app"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test
        run: echo "Running tests"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying"
