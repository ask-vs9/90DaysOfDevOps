# Day 46 -- Reusable Workflows & Composite Actions in GitHub Actions

## Overview

Day 46 focused on understanding and implementing **Reusable Workflows**
and **Composite Actions** in GitHub Actions.

The implementation covered:

-   Reusable workflows using `workflow_call`
-   Workflow inputs, secrets, and outputs
-   Calling a reusable workflow
-   Passing inputs and secrets
-   Returning outputs
-   Custom Composite Actions
-   Composite Action inputs and outputs
-   Calling a local Composite Action
-   Verifying Action outputs
-   Runner information
-   GitHub Actions workflow verification

------------------------------------------------------------------------

# Part 1 -- Reusable Workflows

## What is a Reusable Workflow?

A reusable workflow is a GitHub Actions workflow that can be called by
another workflow.

Reusable workflows use:

``` yaml
on:
  workflow_call:
```

This allows common CI/CD logic to be reused without duplicating the
workflow.

------------------------------------------------------------------------

# Task 1 -- Create a Reusable Workflow

Created:

`.github/workflows/reusable-build.yml`

``` yaml
name: Reusable Build

on:
  workflow_call:
    inputs:
      app_name:
        description: "Application name"
        required: true
        type: string

      environment:
        description: "Deployment environment"
        required: false
        default: staging
        type: string

    secrets:
      docker_token:
        description: "Docker Hub token"
        required: true

    outputs:
      build_version:
        description: "Generated build version"
        value: ${{ jobs.build.outputs.build_version }}

jobs:
  build:
    runs-on: ubuntu-latest

    outputs:
      build_version: ${{ steps.version.outputs.build_version }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Build Application
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Verify Docker Token
        run: |
          if [ -n "${{ secrets.docker_token }}" ]; then
            echo "Docker token is set: true"
          else
            echo "Docker token is set: false"
          fi

      - name: Generate Build Version
        id: version
        shell: bash
        run: |
          SHORT_SHA="${GITHUB_SHA::7}"
          BUILD_VERSION="v1.0-${SHORT_SHA}"

          echo "build_version=${BUILD_VERSION}" >> "$GITHUB_OUTPUT"
          echo "Build version: ${BUILD_VERSION}"
```

------------------------------------------------------------------------

# Task 2 -- Workflow Inputs

The reusable workflow accepts two inputs.

### Application Name

``` yaml
app_name:
  description: "Application name"
  required: true
  type: string
```

### Environment

``` yaml
environment:
  description: "Deployment environment"
  required: false
  default: staging
  type: string
```

The caller passes:

``` yaml
with:
  app_name: "my-web-app"
  environment: "production"
```

The GitHub Actions log showed:

``` text
Building my-web-app for production
```

------------------------------------------------------------------------

# Task 3 -- Workflow Secrets

The reusable workflow accepts a Docker Hub token:

``` yaml
secrets:
  docker_token:
    description: "Docker Hub token"
    required: true
```

The caller passes the repository secret:

``` yaml
secrets:
  docker_token: ${{ secrets.DOCKER_TOKEN }}
```

The workflow verifies that the secret exists without exposing its value:

``` text
Docker token is set: true
```

------------------------------------------------------------------------

# Task 4 -- Workflow Outputs

The workflow generates a build version from the Git commit SHA:

``` bash
SHORT_SHA="${GITHUB_SHA::7}"
BUILD_VERSION="v1.0-${SHORT_SHA}"
echo "build_version=${BUILD_VERSION}" >> "$GITHUB_OUTPUT"
```

The job exposes the output:

``` yaml
outputs:
  build_version: ${{ steps.version.outputs.build_version }}
```

The reusable workflow exposes the job output:

``` yaml
outputs:
  build_version:
    description: "Generated build version"
    value: ${{ jobs.build.outputs.build_version }}
```

------------------------------------------------------------------------

# Part 2 -- Calling the Reusable Workflow

Created:

`.github/workflows/call-build.yml`

``` yaml
name: Call Reusable Build

on:
  push:
    branches:
      - main

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml

    with:
      app_name: "my-web-app"
      environment: "production"

    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  show-version:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Show Build Version
        run: |
          echo "Build version from reusable workflow: ${{ needs.build.outputs.build_version }}"
```

The caller accesses the reusable workflow output using:

``` yaml
${{ needs.build.outputs.build_version }}
```

The successful GitHub Actions run displayed:

``` text
Build version from reusable workflow: v1.0-1094166
```

------------------------------------------------------------------------

# Reusable Workflow Flow

``` text
Caller Workflow
       |
       | app_name
       | environment
       | docker_token
       v
Reusable Workflow
       |
       +-- Checkout Code
       +-- Build Application
       +-- Verify Docker Token
       +-- Generate Build Version
       |
       v
build_version
       |
       v
Caller Workflow
       |
       +-- Show Build Version
```

------------------------------------------------------------------------

# Part 3 -- Composite Actions

## What is a Composite Action?

A Composite Action packages multiple workflow steps into a reusable
action.

A custom Composite Action is defined using:

``` text
action.yml
```

------------------------------------------------------------------------

# Task 5 -- Create a Custom Composite Action

Created:

`.github/actions/setup-and-greet/action.yml`

``` yaml
name: Setup and Greet

description: A custom composite action that prints a greeting and runner information

inputs:
  name:
    description: "Name to greet"
    required: true

  language:
    description: "Greeting language"
    required: false
    default: "en"

outputs:
  greeted:
    description: "Whether the greeting was completed"
    value: ${{ steps.greet.outputs.greeted }}

runs:
  using: "composite"

  steps:
    - name: Print Greeting
      id: greet
      shell: bash
      run: |
        case "${{ inputs.language }}" in
          en)
            echo "Hello, ${{ inputs.name }}!"
            ;;

          hi)
            echo "Namaste, ${{ inputs.name }}!"
            ;;

          es)
            echo "Hola, ${{ inputs.name }}!"
            ;;

          *)
            echo "Hello, ${{ inputs.name }}!"
            ;;
        esac

        echo "Current date: $(date)"
        echo "Runner OS: $RUNNER_OS"

        echo "greeted=true" >> "$GITHUB_OUTPUT"
```

------------------------------------------------------------------------

# Task 6 -- Composite Action Inputs

The action accepts:

``` yaml
name:
  description: "Name to greet"
  required: true
```

and:

``` yaml
language:
  description: "Greeting language"
  required: false
  default: "en"
```

Supported language values are:

-   `en`
-   `hi`
-   `es`

------------------------------------------------------------------------

# Task 7 -- Composite Action Output

The Composite Action creates the `greeted` output:

``` yaml
outputs:
  greeted:
    description: "Whether the greeting was completed"
    value: ${{ steps.greet.outputs.greeted }}
```

The output is generated with:

``` bash
echo "greeted=true" >> "$GITHUB_OUTPUT"
```

------------------------------------------------------------------------

# Task 8 -- Create Workflow to Use Composite Action

Created:

`.github/workflows/composite-greet.yml`

``` yaml
name: Composite Action Greeting

on:
  push:
    branches:
      - main

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Run Setup and Greet
        id: greeting
        uses: ./.github/actions/setup-and-greet

        with:
          name: "Avinash"
          language: "en"

      - name: Verify Greeting Output
        run: |
          echo "Greeted: ${{ steps.greeting.outputs.greeted }}"
```

------------------------------------------------------------------------

# Task 9 -- Verify Composite Action

The GitHub Actions run completed successfully.

The action printed:

``` text
Hello, Avinash!
Current date: Sun Sep 13 03:26:15 UTC 2026
Runner OS: Linux
```

The output verification displayed:

``` text
Greeted: true
```

This confirms that:

-   The Composite Action executed successfully.
-   Inputs were passed correctly.
-   The greeting was generated.
-   Runner information was displayed.
-   The output was successfully consumed by the calling workflow.

------------------------------------------------------------------------

# Composite Action Flow

``` text
GitHub Actions Workflow
          |
          v
Checkout Code
          |
          v
Composite Action
          |
          +-- Receive name
          +-- Receive language
          +-- Print greeting
          +-- Print current date
          +-- Print runner OS
          +-- Generate greeted output
                    |
                    v
              greeted=true
                    |
                    v
          Verify Greeting Output
```

------------------------------------------------------------------------

# Reusable Workflow vs Composite Action

  ---------------------------------------------------------------------------
  Feature                 Reusable Workflow           Composite Action
  ----------------------- --------------------------- -----------------------
  Purpose                 Reuse complete workflow     Reuse a collection of
                          logic                       steps

  Definition              `.github/workflows/*.yml`   `action.yml`

  Invocation              `workflow_call`             `uses:`

  Jobs                    Can contain jobs            Runs inside a job

  Inputs                  Supported                   Supported

  Secrets                 Supported                   Values can be passed
                                                      through supported
                                                      mechanisms

  Outputs                 Supported                   Supported

  Runner                  Defines jobs/runners        Executes inside calling
                                                      job

  Best Use                Reusing CI/CD workflows     Reusing repeated steps
  ---------------------------------------------------------------------------

------------------------------------------------------------------------

# Files Created

``` text
.github/
├── actions/
│   └── setup-and-greet/
│       └── action.yml
│
└── workflows/
    ├── reusable-build.yml
    ├── call-build.yml
    └── composite-greet.yml
```

------------------------------------------------------------------------

# GitHub Actions Results

## Reusable Workflow

Successful run:

``` text
Build version from reusable workflow: v1.0-1094166
```

The caller successfully received the output from the reusable workflow.

## Composite Action

Successful run:

``` text
Hello, Avinash!
Current date: Sun Sep 13 03:26:15 UTC 2026
Runner OS: Linux
Greeted: true
```

------------------------------------------------------------------------

# Key Takeaways

-   `workflow_call` is used to create reusable workflows.
-   Reusable workflows can receive inputs.
-   Reusable workflows can receive secrets.
-   Reusable workflows can return outputs.
-   Caller workflows can consume reusable workflow outputs.
-   Composite Actions package multiple steps into reusable actions.
-   `action.yml` defines a Composite Action.
-   Composite Actions can accept inputs.
-   Composite Actions can generate outputs.
-   `$GITHUB_OUTPUT` is used to create step outputs.
-   Local Composite Actions can be referenced using a relative `uses:`
    path.
-   Reusable workflows are useful for complete CI/CD workflow reuse.
-   Composite Actions are useful for repeated workflow steps.
-   Both approaches reduce duplication and improve maintainability.

------------------------------------------------------------------------

# GitHub Repositories

## GitHub Actions Practice

https://github.com/ask-vs9/github-actions-practice

## 90DaysOfDevOps

https://github.com/ask-vs9/90DaysOfDevOps

------------------------------------------------------------------------

# Day 46 Summary

Day 46 provided hands-on experience with **Reusable Workflows** and
**Composite Actions** in GitHub Actions.

The Reusable Workflow implementation demonstrated workflow inputs,
secrets, outputs, `workflow_call`, and communication between a reusable
workflow and its caller.

The Composite Action implementation demonstrated how multiple steps can
be packaged into a custom action using `action.yml`, accept inputs,
generate outputs, and be called from a workflow.

This hands-on implementation strengthened my understanding of GitHub
Actions workflow reusability, automation, inputs, secrets, outputs, and
custom actions.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
