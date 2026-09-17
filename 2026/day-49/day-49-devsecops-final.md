# Day 49 -- DevSecOps: Add Security to Your CI/CD Pipeline

# Overview

Day 49 focused on integrating security directly into the CI/CD
lifecycle. The implementation added container vulnerability scanning
with Trivy, verified GitHub Secret Scanning and Push Protection, enabled
Dependency Graph, added Dependency Review to Pull Requests, and applied
least-privilege GitHub Actions permissions.

The final workflow follows a security-gated delivery model: code is
tested, dependencies are reviewed, the Docker image is built and
scanned, and only a passing image is pushed and deployed.

------------------------------------------------------------------------

# What is DevSecOps?

DevSecOps is the practice of integrating security throughout the
software development and delivery lifecycle instead of treating security
as a separate activity after deployment.

In this project, security was integrated through:

-   Secret Scanning
-   Push Protection
-   Dependency Graph
-   Dependency Review
-   Trivy container scanning
-   Least-privilege workflow permissions
-   Security gates before Docker push and deployment

------------------------------------------------------------------------

# Day 49 Objectives

1.  Scan the Docker image for vulnerabilities.
2.  Configure Trivy to fail on HIGH and CRITICAL vulnerabilities.
3.  Enable and verify Secret Scanning.
4.  Enable and verify Push Protection.
5.  Enable Dependency Graph.
6.  Add Dependency Review to the Pull Request pipeline.
7.  Configure workflow permissions.
8.  Build and verify a secure CI/CD pipeline.
9.  Document the implementation and results.

------------------------------------------------------------------------

# Part 1 -- Docker Image Vulnerability Scanning

## Objective

The first task was to scan the Docker image for known vulnerabilities
using Trivy. The scan was placed after the Docker image was built and
before it was pushed to Docker Hub.

The security gate was configured to fail when HIGH or CRITICAL
vulnerabilities were detected.

## Initial Scan Result

The initial Debian-based Python image produced:

-   60 vulnerabilities
-   55 HIGH vulnerabilities
-   5 CRITICAL vulnerabilities

Examples included CVE-2025-7458, CVE-2026-13221, CVE-2026-42496,
CVE-2026-8376 and CVE-2023-45853.

This demonstrated that an application can have clean application
dependencies while the underlying container operating system still
contains vulnerable packages.

------------------------------------------------------------------------

# Part 2 -- Secure Docker Base Image

The Docker base image was changed from the Debian-based Python image to
Alpine:

    FROM python:3.12-alpine

Because Alpine uses `apk` rather than `apt-get`, the package upgrade
section was also changed.

## Final Dockerfile

    FROM python:3.12-alpine

    WORKDIR /app

    RUN apk update \
        && apk upgrade \
        && rm -rf /var/cache/apk/*

    COPY app/requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    EXPOSE 5000

    CMD ["python", "app.py"]

## Final Local Trivy Result

The rebuilt image reported:

    OS: Alpine Linux 3.24.1
    Image vulnerabilities: 0
    Python package vulnerabilities: 0

The final image therefore passed the configured security threshold.

------------------------------------------------------------------------

# Part 3 -- Trivy Security Gate

File:

    .github/workflows/reusable-docker.yml

The important pipeline sequence is:

    Docker Build
          ↓
    Trivy Security Scan
          ↓
    Docker Login
          ↓
    Docker Push

## Final Reusable Docker Workflow

    name: Reusable Docker Build and Push

    on:
      workflow_call:
        inputs:
          image_name:
            description: "Docker Hub image name"
            required: true
            type: string

          tag:
            description: "Docker image tag"
            required: true
            type: string

        secrets:
          docker_username:
            description: "Docker Hub username"
            required: true

          docker_token:
            description: "Docker Hub access token"
            required: true

        outputs:
          image_url:
            description: "Full Docker image URL"
            value: ${{ jobs.docker.outputs.image_url }}

    jobs:
      docker:
        runs-on: ubuntu-latest

        outputs:
          image_url: ${{ steps.image.outputs.image_url }}

        permissions:
          contents: read

        steps:
          - name: Checkout Code
            uses: actions/checkout@v4

          - name: Set up Docker Buildx
            uses: docker/setup-buildx-action@v3

          - name: Set Short SHA
            id: vars
            shell: bash
            run: |
              echo "short_sha=${GITHUB_SHA::7}" >> "$GITHUB_OUTPUT"

          - name: Build Docker Image
            uses: docker/build-push-action@v6
            with:
              context: .
              load: true
              push: false
              tags: |
                ${{ inputs.image_name }}:${{ inputs.tag }}
                ${{ inputs.image_name }}:sha-${{ steps.vars.outputs.short_sha }}

          - name: Scan Docker Image for Vulnerabilities
            uses: aquasecurity/trivy-action@v0.36.0
            with:
              version: v0.74.0
              scan-type: image
              image-ref: ${{ inputs.image_name }}:${{ inputs.tag }}
              format: table
              exit-code: 1
              severity: CRITICAL,HIGH

          - name: Login to Docker Hub
            uses: docker/login-action@v3
            with:
              username: ${{ secrets.docker_username }}
              password: ${{ secrets.docker_token }}

          - name: Push Docker Image
            shell: bash
            run: |
              docker push "${{ inputs.image_name }}:${{ inputs.tag }}"
              docker push "${{ inputs.image_name }}:sha-${{ steps.vars.outputs.short_sha }}"

          - name: Set Image URL
            id: image
            run: |
              echo "image_url=${{ inputs.image_name }}:${{ inputs.tag }}" >> "$GITHUB_OUTPUT"

## Trivy Configuration Explained

### `load: true`

Loads the built image into the runner's local Docker image store so
Trivy can scan it.

### `push: false`

Prevents the build step from publishing the image before the security
scan.

### `severity: CRITICAL,HIGH`

Tells Trivy to treat HIGH and CRITICAL findings as security-gate
findings.

### `exit-code: 1`

Causes the Trivy step to fail when matching vulnerabilities are found.

------------------------------------------------------------------------

# Trivy Security Flow

    Checkout Code
          ↓
    Docker Build
          ↓
    Load Image
          ↓
    Trivy Scan
          ↓
      Scan Passes?
       /       \
     NO         YES
     ↓           ↓
    STOP       Login
                 ↓
             Docker Push
                 ↓
              Deploy

------------------------------------------------------------------------

# Part 4 -- GitHub Secret Scanning

Secret Scanning was enabled and verified in the repository security
settings.

The repository Secret Scanning page showed:

    0 Open
    0 Closed

The repository also showed Secret Protection as enabled.

Secret Scanning helps detect supported credentials and secrets such as
API tokens, cloud credentials, private keys, and other sensitive
authentication material.

------------------------------------------------------------------------

# Part 5 -- Push Protection

Push Protection was enabled in the repository security settings.

Push Protection complements Secret Scanning by helping prevent supported
secrets from being pushed into the repository in the first place.

## Secret Scanning vs Push Protection

### Secret Scanning

Detects supported secrets that are present in repository content.

### Push Protection

Helps prevent supported secrets from entering the repository during a
push.

## Security Flow

    Developer
        ↓
    Git Push
        ↓
    Push Protection
        ↓
    Secret detected?
       / \
     YES  NO
      ↓    ↓
    Block  Push

Real AWS credentials or production secrets should never be intentionally
committed for testing. A documented test secret should be used when an
official test mechanism is available.

------------------------------------------------------------------------

# Part 6 -- Dependency Graph

Dependency Review requires the repository Dependency Graph to be
available.

The first Dependency Review run failed because Dependency Graph was not
enabled. GitHub reported that dependency review was not supported on the
repository and requested that Dependency Graph be enabled.

Dependency Graph was then enabled in the repository security settings.

The Dependency Review workflow was re-run after the change and passed
successfully.

------------------------------------------------------------------------

# Part 7 -- Dependency Review

## Objective

Dependency Review was added to the Pull Request pipeline to check
dependency changes introduced by a Pull Request.

The action was configured to fail on critical dependency
vulnerabilities.

## Updated PR Pipeline

File:

    .github/workflows/pr-pipeline.yml

    name: PR Pipeline

    on:
      pull_request:
        branches:
          - main
        types:
          - opened
          - synchronize

    permissions:
      contents: read

    jobs:
      dependency-review:
        name: Dependency Review
        runs-on: ubuntu-latest

        steps:
          - name: Check Dependencies for Vulnerabilities
            uses: actions/dependency-review-action@v4
            with:
              fail-on-severity: critical

      build-test:
        name: Build and Test
        uses: ./.github/workflows/reusable-build-test.yml
        with:
          python_version: "3.12"
          run_tests: true

      pr-comment:
        name: PR Check Message
        needs:
          - build-test
          - dependency-review
        runs-on: ubuntu-latest

        steps:
          - name: Show PR Check Result
            run: |
              echo "PR checks passed for branch: ${{ github.head_ref }}"
              echo "Dependency review passed."

------------------------------------------------------------------------

# Dependency Review Flow

    Pull Request
          ↓
    Dependency Review
          ↓
    Critical vulnerability check
          ↓
      Review passes?
       /          \
     NO            YES
     ↓              ↓
    Fail        Build & Test
                    ↓
              PR Check Message

------------------------------------------------------------------------

# Part 8 -- Testing Dependency Review

A feature branch was created:

    feature/day49-dependency-review

The dependency was changed from:

    Flask==3.1.2

to:

    Flask==3.1.3

The Pull Request was created against `main`.

## Pull Request #4

Title:

    Day 49 - Dependency Review Test

The Pull Request documented the dependency change and the new Dependency
Review configuration.

## Initial Failure

The first Dependency Review execution failed because Dependency Graph
was disabled.

The error indicated:

    Dependency review is not supported on this repository.
    Please ensure that Dependency graph is enabled.

After enabling Dependency Graph, the workflow was re-run.

## Successful Result

The final Dependency Review result showed:

    No vulnerabilities or license issues or OpenSSF Scorecard issues found.

The scan included:

    app/requirements.txt

and reported:

    pip/Flask 3.1.3

The Pull Request was successfully merged after the dependency-review
issue was resolved.

------------------------------------------------------------------------

# Part 9 -- Workflow Permissions

The principle of least privilege was applied by explicitly restricting
GitHub Actions permissions.

Two workflow files contain explicit `contents: read` permissions.

## PR Pipeline

File:

    .github/workflows/pr-pipeline.yml

    permissions:
      contents: read

## Reusable Docker Workflow

File:

    .github/workflows/reusable-docker.yml

    jobs:
      docker:
        runs-on: ubuntu-latest

        permissions:
          contents: read

Only the permissions required by the workflow are granted instead of
unnecessary write permissions.

------------------------------------------------------------------------

# Part 10 -- Complete Secure CI/CD Pipeline

The final secure delivery flow is:

    Pull Request
          ↓
    Build & Test
          ↓
    Dependency Review
          ↓
    PR Validation
          ↓
    Merge to main
          ↓
    Build & Test
          ↓
    Docker Build
          ↓
    Trivy Security Scan
          ↓
    Docker Push
          ↓
    Production Deployment

## Secure Pipeline Diagram

    ┌─────────────────────┐
    │ Pull Request Opened │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │ Build & Test        │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │ Dependency Review   │
    │ Critical Check      │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │ PR Validation       │
    └──────────┬──────────┘
               ↓
             Merge
               ↓
    ┌─────────────────────┐
    │ Build & Test        │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │ Docker Build        │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │ Trivy Image Scan    │
    │ HIGH / CRITICAL     │
    └──────────┬──────────┘
               ↓
          Scan Passed?
          /          \
        NO            YES
        ↓              ↓
      STOP         Docker Push
                       ↓
                    Deploy

------------------------------------------------------------------------

# Always-Active Security Controls

    GitHub Secret Scanning
              +
       Push Protection
              +
       Dependency Graph
              +
       Dependency Review
              +
       Trivy Container Scan
              +
    Least-Privilege Permissions

------------------------------------------------------------------------

# Part 11 -- Files Created and Modified

## Modified: Dockerfile

Changed the base image to:

    FROM python:3.12-alpine

and replaced Debian package-management commands with Alpine `apk`
commands.

## Modified: `.github/workflows/reusable-docker.yml`

Changes:

-   Added explicit `contents: read` permissions.
-   Changed the Docker build to load the image locally.
-   Added Trivy scanning before Docker push.
-   Configured HIGH and CRITICAL severity handling.
-   Moved Docker login after the security scan.
-   Added explicit Docker push commands after the scan.

## Modified: `.github/workflows/pr-pipeline.yml`

Changes:

-   Added `contents: read` permissions.
-   Added Dependency Review.
-   Configured `fail-on-severity: critical`.
-   Made the final PR check depend on Build and Test and Dependency
    Review.

## Modified for Testing: `app/requirements.txt`

Changed:

    Flask==3.1.2

to:

    Flask==3.1.3

------------------------------------------------------------------------

# Part 12 -- Git Commands Used

    cd ~/Downloads/github-actions-practice

    git checkout main

    git pull origin main

    git status

The final local repository state showed:

    On branch main
    Your branch is up to date with 'origin/main'.
    nothing to commit, working tree clean

The dependency-review test branch was:

    git checkout -b feature/day49-dependency-review

After the Pull Request was merged, the feature branch was deleted.

------------------------------------------------------------------------

# Part 13 -- GitHub Actions Results

## Trivy

Final scan:

    Alpine 3.24.1
    0 vulnerabilities

Status: PASS

## Dependency Review

Final result:

    No vulnerabilities or license issues or OpenSSF Scorecard issues found.

Status: PASS

## Build and Test

Status: PASS

## PR Validation

Branch Name Check: PASS

File Size Check: PASS

PR Description Check: PASS

## Pull Request

Pull Request #4 was successfully merged into `main` and the feature
branch was deleted.

------------------------------------------------------------------------

# Part 14 -- Failure and Fix Summary

  -----------------------------------------------------------------------
  Issue                   Result                  Resolution
  ----------------------- ----------------------- -----------------------
  Debian-based image      Trivy failed            Changed base image
  contained                                       
  vulnerabilities                                 

  Dockerfile still used   Docker build failed     Replaced with `apk`
  `apt-get` after                                 
  switching to Alpine                             

  Trivy reported          Security gate failed    Updated base image
  HIGH/CRITICAL findings                          

  Dependency Review       Dependency Graph        Enabled Dependency
  initially failed        unavailable             Graph

  Dependency Review after Passed                  No further change
  enabling graph                                  required

  Old Day 43 conditional  Unrelated existing      Left unchanged
  checks failed           workflow                
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# Part 15 -- Security Lessons Learned

## 1. Security should run before deployment

The Docker image is scanned before it is pushed to the registry.

## 2. Base images matter

Container vulnerabilities can come from operating-system packages even
when application dependencies are clean.

## 3. Dependency security belongs in Pull Requests

Dependency Review provides security feedback while dependency changes
are being reviewed.

## 4. Prevention is important for secrets

Push Protection can prevent supported secrets from entering the
repository, while Secret Scanning helps detect supported secrets in
repository content.

## 5. Least privilege reduces unnecessary access

Explicit `contents: read` permissions avoid granting unnecessary write
access to the workflows.

## 6. Security gates should block unsafe artifacts

A failing Trivy step prevents the Docker push step from executing.

------------------------------------------------------------------------

# Part 16 -- Final DevSecOps Flow

    Developer
        │
        ▼
    Pull Request
        │
        ├──────────────► Build & Test
        │
        ├──────────────► Dependency Review
        │
        └──────────────► PR Validation
                         │
                         ▼
                       Merge
                         │
                         ▼
                    Build & Test
                         │
                         ▼
                    Docker Build
                         │
                         ▼
                    Trivy Scan
                         │
                    ┌────┴────┐
                    │         │
                  FAIL       PASS
                    │         │
                    ▼         ▼
                  STOP    Docker Push
                              │
                              ▼
                         Deployment

Repository security:

    Secret Scanning + Push Protection + Dependency Graph + Least-Privilege Permissions

------------------------------------------------------------------------

# Part 17 -- Screenshots

Add the following screenshots to this directory when available.

## Trivy Security Scan

    ![Day 49 - Trivy Security Scan](./day49-trivy-scan.png)

## Secret Scanning

    ![Day 49 - Secret Scanning](./day49-secret-scanning.png)

## Secret Protection and Push Protection

    ![Day 49 - Secret Protection and Push Protection](./day49-secret-protection.png)

## Dependency Review

    ![Day 49 - Dependency Review](./day49-dependency-review.png)

## Pull Request

    ![Day 49 - Dependency Review Pull Request](./day49-pr-merged.png)

------------------------------------------------------------------------

# Part 18 -- GitHub Actions Evidence

The Dependency Review workflow initially failed because Dependency Graph
was disabled. After enabling the graph, the workflow completed
successfully.

The successful Dependency Review summary showed:

    No vulnerabilities or license issues or OpenSSF Scorecard issues found.

The workflow graph showed Build and Test and Dependency Review feeding
the final PR Check Message job.

The container pipeline successfully passed the Trivy security gate after
the Docker base image was changed to Alpine.

------------------------------------------------------------------------

# Part 18 -- Screenshot Evidence

For Day 49, the available screenshot evidence is the final local Trivy
security scan.

## Trivy Security Scan

The final scan shows:

- Alpine Linux 3.24.1
- 0 image vulnerabilities
- 0 Python package vulnerabilities

The screenshot also shows that Trivy secret scanning is enabled.

<img width="1920" height="1030" alt="Screenshot 2026-09-17 212444" src="https://github.com/user-attachments/assets/9cd86853-5a92-4bfa-8773-cc22aff712ee" />

The other Day 49 security controls were verified directly in GitHub:

- Secret Scanning enabled
- Push Protection enabled
- Dependency Graph enabled
- Dependency Review passed
- Workflow permissions configured in two workflow files
- Pull Request #4 successfully merged
- Feature branch deleted

------------------------------------------------------------------------

# Part 19 -- Security Gate Behavior

If a matching HIGH or CRITICAL vulnerability is found:

    Trivy
      ↓
    exit code 1
      ↓
    Job fails
      ↓
    Docker push does not run
      ↓
    Deployment does not continue

If the scan passes:

    Trivy
      ↓
    exit code 0
      ↓
    Docker login
      ↓
    Docker push
      ↓
    Deployment

This creates a security checkpoint before the container artifact reaches
Docker Hub.

------------------------------------------------------------------------

# Part 20 -- DevSecOps Coverage

## Source Control Security

-   Secret Scanning
-   Push Protection

## Pull Request Security

-   Dependency Review
-   PR validation
-   Least-privilege permissions

## Container Security

-   Trivy vulnerability scanning
-   Secure base image selection

## Deployment Security

-   Deployment follows the container security gate

------------------------------------------------------------------------

# Part 21 -- Key Takeaways

✔️ Integrated Trivy into GitHub Actions.

✔️ Learned how container base images affect vulnerability results.

✔️ Implemented a security gate before Docker push.

✔️ Verified a final Trivy result of zero vulnerabilities.

✔️ Enabled and verified GitHub Secret Scanning.

✔️ Enabled and verified Push Protection.

✔️ Learned the difference between Secret Scanning and Push Protection.

✔️ Enabled Dependency Graph.

✔️ Added Dependency Review to the Pull Request pipeline.

✔️ Configured Dependency Review to fail on critical dependency
vulnerabilities.

✔️ Added explicit `contents: read` permissions to two workflow files.

✔️ Applied the principle of least privilege.

✔️ Integrated security controls into CI/CD.

✔️ Validated the implementation using a real Pull Request.

------------------------------------------------------------------------

# Part 22 -- Final Day 49 Checklist

  Requirement                             Status
  --------------------------------------- ----------------------
  Docker image vulnerability scan         ✅ Completed
  Trivy integrated into CI/CD             ✅ Completed
  Trivy scans before Docker push          ✅ Completed
  Trivy fails on HIGH/CRITICAL            ✅ Completed
  Vulnerability findings investigated     ✅ Completed
  Secure base image selected              ✅ Completed
  Final Trivy result                      ✅ 0 vulnerabilities
  Secret Scanning enabled                 ✅ Completed
  Push Protection enabled                 ✅ Completed
  Dependency Graph enabled                ✅ Completed
  Dependency Review added                 ✅ Completed
  Dependency Review tested through PR     ✅ Completed
  Dependency Review passed                ✅ Completed
  Workflow permissions added              ✅ Completed
  Permissions added to 2 workflow files   ✅ Completed
  Secure pipeline implemented             ✅ Completed
  PR #4 merged                            ✅ Completed
  Feature branch deleted                  ✅ Completed

------------------------------------------------------------------------

# GitHub Repositories

## GitHub Actions Practice

https://github.com/ask-vs9/github-actions-practice

## 90DaysOfDevOps

https://github.com/ask-vs9/90DaysOfDevOps

------------------------------------------------------------------------

# Day 49 Summary

Day 49 focused on adding security directly into a practical CI/CD
pipeline using DevSecOps principles.

I integrated Trivy container vulnerability scanning and configured the
workflow so HIGH and CRITICAL vulnerabilities can block the Docker image
from being pushed. The initial Debian-based image contained multiple
vulnerabilities, so I changed the base image to Alpine and verified a
final Trivy result of zero vulnerabilities.

I also enabled and verified Secret Scanning and Push Protection, enabled
Dependency Graph, and added Dependency Review to the Pull Request
pipeline. The Dependency Review implementation was tested through Pull
Request #4 and successfully passed after Dependency Graph was enabled.

Finally, I added explicit `contents: read` permissions to two workflow
files and applied the principle of least privilege.

This hands-on implementation strengthened my understanding of container
security, dependency security, secret protection, GitHub Actions
permissions, and security gates within CI/CD.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
