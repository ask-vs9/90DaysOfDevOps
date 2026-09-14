# Day 47 -- Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

## Overview

Day 47 focused on understanding and implementing advanced GitHub Actions triggers.

The implementation covered:

  * Pull Request lifecycle events
  * Pull Request validation
  * Scheduled workflows using cron
  * Manual workflow execution
  * Path-based triggers
  * paths and paths-ignore
  * Workflow chaining using workflow_run
  * External event triggers using repository_dispatch
  * Branch filters
  * Event-driven CI/CD pipelines

* * *

# Part 1 -- Pull Request Lifecycle Events

## What are Pull Request Lifecycle Events?

A Pull Request lifecycle event allows GitHub Actions to respond to
different activities performed on a Pull Request.

The workflow uses:

    pull_request:
      types:
        - opened
        - synchronize
        - reopened
        - closed

* * *

# Task 1 -- Create PR Lifecycle Workflow

Created:

`.github/workflows/pr-lifecycle.yml`

    name: PR Lifecycle Events

    on:
      pull_request:
        types:
          - opened
          - synchronize
          - reopened
          - closed

    jobs:
      pr-details:
        runs-on: ubuntu-latest

        steps:
          - name: Print PR Event Details
            run: |
              echo "PR event: ${{ github.event.action }}"
              echo "PR title: ${{ github.event.pull_request.title }}"
              echo "PR author: ${{ github.event.pull_request.user.login }}"
              echo "Source branch: ${{ github.event.pull_request.head.ref }}"
              echo "Target branch: ${{ github.event.pull_request.base.ref }}"

          - name: Check if PR was merged
            if: github.event.action == 'closed' && github.event.pull_request.merged == true
            run: |
              echo "PR was merged successfully!"
              echo "Merged PR: #${{ github.event.pull_request.number }}"
              echo "Source branch: ${{ github.event.pull_request.head.ref }}"
              echo "Target branch: ${{ github.event.pull_request.base.ref }}"

          - name: Check if PR was closed without merge
            if: github.event.action == 'closed' && github.event.pull_request.merged != true
            run: |
              echo "PR was closed without being merged."

* * *

# Task 2 -- PR Event Information

The workflow displays:

### Event Action

    github.event.action

### PR Title

    github.event.pull_request.title

### PR Author

    github.event.pull_request.user.login

### Source Branch

    github.event.pull_request.head.ref

### Target Branch

    github.event.pull_request.base.ref

* * *

# Task 3 -- Detecting a Merged Pull Request

A closed Pull Request does not necessarily mean that it was merged.

The workflow checks:

    github.event.action == 'closed'

and:

    github.event.pull_request.merged == true

The merged-only condition is:

    if: github.event.action == 'closed' && github.event.pull_request.merged == true

This allows the workflow to distinguish between:

    PR closed and merged

and:

    PR closed without merge

* * *

# Part 2 -- Pull Request Validation

# Task 4 -- Create PR Validation Workflow

Created:

`.github/workflows/pr-checks.yml`

    name: PR Validation Checks

    on:
      pull_request:
        branches:
          - main

    jobs:
      file-size-check:
        name: File Size Check
        runs-on: ubuntu-latest

        steps:
          - name: Checkout Code
            uses: actions/checkout@v4
            with:
              fetch-depth: 0

          - name: Check Changed File Sizes
            shell: bash
            run: |
              echo "Checking changed files for size limits..."

              BASE_SHA="${{ github.event.pull_request.base.sha }}"
              HEAD_SHA="${{ github.event.pull_request.head.sha }}"

              oversized_files=0

              while IFS= read -r file; do
                if [ -f "$file" ]; then
                  size=$(wc -c < "$file")

                  if [ "$size" -gt 1048576 ]; then
                    echo "ERROR: $file is larger than 1 MB ($size bytes)"
                    oversized_files=$((oversized_files + 1))
                  else
                    echo "OK: $file ($size bytes)"
                  fi
                fi
              done < <(git diff --name-only "$BASE_SHA" "$HEAD_SHA")

              if [ "$oversized_files" -gt 0 ]; then
                echo "File size check failed."
                exit 1
              fi

              echo "File size check passed."

      branch-name-check:
        name: Branch Name Check
        runs-on: ubuntu-latest

        steps:
          - name: Validate Branch Name
            shell: bash
            run: |
              BRANCH_NAME="${{ github.head_ref }}"

              echo "Checking branch: $BRANCH_NAME"

              if [[ "$BRANCH_NAME" =~ ^feature/.+ ]] || \
                 [[ "$BRANCH_NAME" =~ ^fix/.+ ]] || \
                 [[ "$BRANCH_NAME" =~ ^docs/.+ ]]; then
                echo "Branch name is valid: $BRANCH_NAME"
              else
                echo "ERROR: Invalid branch name: $BRANCH_NAME"
                echo "Allowed patterns:"
                echo "  feature/*"
                echo "  fix/*"
                echo "  docs/*"
                exit 1
              fi

      pr-body-check:
        name: PR Description Check
        runs-on: ubuntu-latest

        steps:
          - name: Check PR Description
            shell: bash
            env:
              PR_BODY: ${{ github.event.pull_request.body }}
            run: |
              if [ -z "$PR_BODY" ]; then
                echo "::warning::PR description is empty. Please add a meaningful description."
              else
                echo "PR description is present."
              fi

* * *

# Task 5 -- File Size Check

The workflow checks all changed files in the Pull Request.

The maximum file size is:

    1 MB = 1,048,576 bytes

The Pull Request base and head commits are stored in:

    BASE_SHA="${{ github.event.pull_request.base.sha }}"
    HEAD_SHA="${{ github.event.pull_request.head.sha }}"

Changed files are identified using:

    git diff --name-only "$BASE_SHA" "$HEAD_SHA"

If a file exceeds 1 MB:

    exit 1

The workflow fails the file-size check.

* * *

# Task 6 -- Branch Name Check

The workflow uses:

    github.head_ref

The allowed branch patterns are:

    feature/*
    fix/*
    docs/*

Examples:

    feature/login-page
    feature/docker-deployment
    fix/api-error
    docs/github-actions

An invalid branch such as:

    test-branch

will fail the check.

* * *

# Task 7 -- Pull Request Body Check

The Pull Request description is retrieved using:

    github.event.pull_request.body

If the description is empty, the workflow creates a warning:

    ::warning::PR description is empty. Please add a meaningful description.

The workflow does not fail.

* * *

# Part 3 -- Scheduled Workflows

# Task 8 -- Create Scheduled Workflow

Created:

`.github/workflows/scheduled-tasks.yml`

    name: Scheduled Tasks

    on:
      schedule:
        - cron: '30 2 * * 1'
        - cron: '0 */6 * * *'
      workflow_dispatch:

    jobs:
      scheduled-health-check:
        name: Scheduled Health Check
        runs-on: ubuntu-latest

        steps:
          - name: Show Trigger Information
            run: |
              echo "Event name: ${{ github.event_name }}"

              if [ "${{ github.event_name }}" = "schedule" ]; then
                echo "Schedule that triggered this workflow: ${{ github.event.schedule }}"
              else
                echo "Workflow was triggered manually."
              fi

          - name: Health Check
            shell: bash
            run: |
              URL="https://github.com"

              echo "Checking: $URL"

              HTTP_STATUS=$(curl -L -s -o /dev/null -w "%{http_code}" "$URL")

              echo "HTTP response code: $HTTP_STATUS"

              if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 400 ]; then
                echo "Health check passed."
              else
                echo "Health check failed."
                exit 1
              fi

* * *

# Task 9 -- Understanding Cron Expressions

GitHub Actions uses POSIX cron syntax.

A cron expression contains five fields:

    * * * * *

The fields are:

    Minute
    Hour
    Day of Month
    Month
    Day of Week

### Monday at 2:30 UTC

    30 2 * * 1

### Every 6 Hours

    0 */6 * * *

### Every Weekday at 9 AM IST

    30 3 * * 1-5

### First Day of Every Month

    0 0 1 * *

* * *

# Task 10 -- Manual Workflow Execution

The scheduled workflow also supports:

    workflow_dispatch:

This allows the workflow to be started manually from GitHub Actions.

For scheduled execution:

    github.event_name

returns:

    schedule

For manual execution:

    github.event_name

returns:

    workflow_dispatch

The scheduled cron expression can be displayed using:

    github.event.schedule

* * *

# Task 11 -- Scheduled Health Check

The workflow checks:

    https://github.com

The HTTP status code is retrieved using:

    curl -L -s -o /dev/null -w "%{http_code}" "$URL"

The workflow considers status codes from 200 through 399 successful.

* * *

# Part 4 -- Smart Path-Based Triggers

# Task 12 -- Create Smart Path Trigger

Created:

`.github/workflows/smart-triggers.yml`

    name: Smart Path Triggers

    on:
      push:
        branches:
          - main
          - 'release/*'
        paths:
          - 'src/**'
          - 'app/**'

    jobs:
      path-trigger-check:
        runs-on: ubuntu-latest

        steps:
          - name: Show Trigger Information
            run: |
              echo "Workflow triggered by a push."
              echo "Branch: ${{ github.ref_name }}"
              echo "Commit: ${{ github.sha }}"
              echo "This workflow runs only when src/** or app/** changes."

* * *

# Task 13 -- Understanding paths

The workflow uses:

    paths:
      - 'src/**'
      - 'app/**'

This means the workflow runs when files inside:

    src/

or:

    app/

are changed.

Examples:

    src/main.py
    src/utils/helper.py
    app/index.js
    app/components/button.js

* * *

# Task 14 -- Create paths-ignore Workflow

Created:

`.github/workflows/smart-docs-ignore.yml`

    name: Smart Docs Ignore

    on:
      push:
        branches:
          - main
          - 'release/*'
        paths-ignore:
          - '*.md'
          - 'docs/**'

    jobs:
      docs-ignore-check:
        runs-on: ubuntu-latest

        steps:
          - name: Show Trigger Information
            run: |
              echo "Workflow triggered by a push."
              echo "Branch: ${{ github.ref_name }}"
              echo "This workflow skips pushes containing only Markdown/docs changes."

* * *

# Task 15 -- paths vs paths-ignore

## paths

`paths` defines which files can trigger the workflow.

Example:

    paths:
      - 'src/**'

## paths-ignore

`paths-ignore` defines files that should be ignored.

Example:

    paths-ignore:
      - '*.md'
      - 'docs/**'

For example:

    README.md
    docs/setup.md

will be ignored when the push contains only those files.

* * *

# Part 5 -- Workflow Chaining

## What is workflow_run?

`workflow_run` allows one workflow to react after another workflow completes.

The CI/CD flow becomes:

    Push
      |
      v
    Run Tests
      |
      v
    Deploy

* * *

# Task 16 -- Create Test Workflow

Created:

`.github/workflows/tests.yml`

    name: Run Tests

    on:
      push:

    jobs:
      test:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout Code
            uses: actions/checkout@v4

          - name: Run Tests
            run: |
              echo "Running tests..."
              echo "All tests passed successfully!"

* * *

# Task 17 -- Create Deployment Workflow

Created:

`.github/workflows/deploy-after-tests.yml`

    name: Deploy After Tests

    on:
      workflow_run:
        workflows: ["Run Tests"]
        types:
          - completed

    jobs:
      deploy:
        runs-on: ubuntu-latest

        steps:
          - name: Check Test Result
            run: |
              echo "Test workflow conclusion: ${{ github.event.workflow_run.conclusion }}"

          - name: Deploy
            if: github.event.workflow_run.conclusion == 'success'
            run: |
              echo "Tests passed successfully."
              echo "Deploying application..."
              echo "Deployment completed successfully."

          - name: Deployment Blocked
            if: github.event.workflow_run.conclusion != 'success'
            run: |
              echo "::warning::Tests did not pass. Deployment will not proceed."
              echo "Test workflow conclusion: ${{ github.event.workflow_run.conclusion }}"
              exit 1

* * *

# Task 18 -- workflow_run Conclusion

The deployment workflow checks:

    github.event.workflow_run.conclusion

If the test workflow succeeds:

    success

the deployment step runs.

If the test workflow fails:

    failure

the deployment is blocked.

The complete flow is:

    Push
      |
      v
    Run Tests
      |
      +---- success ----> Deploy
      |
      +---- failure ----> Deployment Blocked

* * *

# Task 19 -- workflow_run vs workflow_call

`workflow_run` is used for workflow chaining.

    Run Tests
        |
        v
    Deploy

`workflow_call` is used for reusable workflows.

    Caller Workflow
          |
          v
    Reusable Workflow

### Comparison

    Feature              workflow_run              workflow_call

    Purpose              Workflow chaining        Workflow reuse

    Trigger              Workflow completion      Explicit caller

    Typical use          Test -> Deploy            Shared CI/CD

    Main concept         Event-driven              Reusable

* * *

# Part 6 -- External Event-Driven Pipelines

# Task 20 -- Create repository_dispatch Workflow

Created:

`.github/workflows/external-trigger.yml`

    name: External Deployment Trigger

    on:
      repository_dispatch:
        types:
          - deploy-request

    jobs:
      external-deploy:
        runs-on: ubuntu-latest

        steps:
          - name: Show Deployment Request
            run: |
              echo "External deployment request received."
              echo "Event type: ${{ github.event.action }}"
              echo "Environment: ${{ github.event.client_payload.environment }}"

          - name: Deploy
            run: |
              echo "Starting deployment..."
              echo "Deploying to: ${{ github.event.client_payload.environment }}"
              echo "Deployment request completed successfully."

* * *

# Task 21 -- Understanding repository_dispatch

`repository_dispatch` allows an external system to send a custom event to a GitHub repository.

Common use cases include:

  * External deployment systems
  * Monitoring systems
  * Infrastructure automation
  * Third-party CI/CD systems
  * Release automation

The workflow listens for:

    deploy-request

* * *

# Task 22 -- Client Payload

The workflow reads:

    github.event.client_payload.environment

Example payload:

    {
      "environment": "production"
    }

The workflow receives:

    production

* * *

# Task 23 -- Trigger repository_dispatch

The GitHub CLI can trigger the event:

    gh api repos/<owner>/<repo>/dispatches \
      -f event_type=deploy-request \
      -f client_payload='{"environment":"production"}'

The event flow is:

    External System
          |
          | repository_dispatch
          | environment=production
          v
    GitHub Repository
          |
          v
    External Deployment Trigger
          |
          v
    Deployment

* * *

# Part 7 -- Advanced Trigger Flow

    Pull Request
          |
          +----> PR Lifecycle
          |
          +----> PR Validation
          |
          v
    GitHub Actions

    Scheduled Time
          |
          v
    Scheduled Workflow
          |
          v
    Health Check

    Repository Push
          |
          +----> Path Filters
          |
          +----> Run Tests
                     |
                     v
                workflow_run
                     |
                     v
                  Deploy

    External System
          |
          v
    repository_dispatch
          |
          v
    Deployment

* * *

# Files Created

    `.github/
    └── workflows/
        ├── pr-lifecycle.yml
        ├── pr-checks.yml
        ├── scheduled-tasks.yml
        ├── smart-triggers.yml
        ├── smart-docs-ignore.yml
        ├── tests.yml
        ├── deploy-after-tests.yml
        └── external-trigger.yml
    `

Documentation:

    `2026/day-47/day-47-advanced-triggers.md`

* * *

# GitHub Actions Results

## PR Lifecycle

The workflow will be tested using:

    opened
    synchronize
    reopened
    closed

For a merged Pull Request:

    PR was merged successfully!

For a closed Pull Request without merge:

    PR was closed without being merged.

## PR Validation

The workflow contains:

    File Size Check
    Branch Name Check
    PR Description Check

## Scheduled Workflow

The scheduled workflow supports:

    Monday 02:30 UTC

and:

    Every 6 hours

It also supports manual execution using:

    workflow_dispatch

## Smart Triggers

The workflow supports path-based execution using:

    src/**
    app/**

Documentation-only changes are ignored by:

    paths-ignore

## Workflow Chaining

The expected CI/CD flow is:

    Push
      |
      v
    Run Tests
      |
      v
    Deploy After Tests

## External Trigger

The expected event payload is:

    {
      "environment": "production"
    }

* * *

# Key Takeaways

  * `pull_request` can react to different Pull Request lifecycle events.
  * `github.event.pull_request.merged` can identify merged Pull Requests.
  * `github.head_ref` identifies the source branch.
  * `paths` controls which file changes trigger workflows.
  * `paths-ignore` excludes selected paths.
  * `schedule` enables cron-based automation.
  * `workflow_dispatch` enables manual execution.
  * `github.event.schedule` identifies the scheduled trigger.
  * `workflow_run` enables workflow chaining.
  * `workflow_call` is designed for reusable workflows.
  * `repository_dispatch` enables external event-driven workflows.
  * `github.event.client_payload` provides custom event data.
  * Branch and path filters help reduce unnecessary workflow executions.
  * Event-driven pipelines improve CI/CD automation and maintainability.

* * *

# GitHub Repositories

## GitHub Actions Practice

https://github.com/ask-vs9/github-actions-practice

## 90DaysOfDevOps

https://github.com/ask-vs9/90DaysOfDevOps

* * *

# Day 47 Summary

Day 47 provided hands-on experience with advanced GitHub Actions triggers and event-driven CI/CD pipelines.

The Pull Request implementation demonstrated how workflows can respond to different Pull Request lifecycle events and validate Pull Request changes.

The scheduled workflow implementation demonstrated cron-based automation, manual workflow execution, and HTTP health checks.

The path-based trigger implementation demonstrated how `paths` and `paths-ignore` can control workflow execution based on changed files.

The `workflow_run` implementation demonstrated how multiple workflows can be chained together to create a Test -> Deploy pipeline.

The `repository_dispatch` implementation demonstrated how external systems can trigger GitHub Actions workflows using custom events and client payload data.

This hands-on implementation strengthened my understanding of GitHub Actions triggers, Pull Request automation, scheduled jobs, path filtering, workflow chaining, external events, and event-driven CI/CD architecture.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
