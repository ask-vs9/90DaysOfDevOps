# 🚀 Day 42 - GitHub Actions Runners (GitHub Hosted & Self Hosted)

## 📌 Objective

Learn how GitHub Actions runners work by:

- Running workflows on GitHub-hosted runners
- Exploring pre-installed software
- Configuring a Self-hosted Runner on AWS EC2
- Running workflows on the self-hosted runner
- Using custom runner labels

---

# Task 1 - GitHub Hosted Runner

Created a workflow that runs on GitHub-hosted runners.

### Result

- Workflow executed successfully
- Verified workflow execution from the Actions tab

## Screenshot

<img width="1920" height="983" alt="Screenshot 2026-07-15 201818" src="https://github.com/user-attachments/assets/95f6fb21-1d8d-4e1c-8bd6-e7b1cb99af59" />


---

# Task 2 - Explore Pre-installed Tools

Verified the versions of tools already installed on GitHub-hosted runners.

Tools checked:

- Docker
- Python
- Node.js
- Git

### Output

- Docker 28.x
- Python 3.12.x
- Node 22.x
- Git 2.54.x

## Screenshot

<img width="1916" height="975" alt="Screenshot 2026-07-15 203105" src="https://github.com/user-attachments/assets/5ab519ca-521a-4ac8-bb39-daf3d4e88ca2" />


---

# Task 3 - Configure Self-hosted Runner

Configured a self-hosted runner on an AWS EC2 Ubuntu instance.

### Steps Performed

- Created runner directory
- Downloaded GitHub Actions Runner
- Extracted package
- Configured runner
- Registered runner with GitHub
- Started runner

```bash
./run.sh
```

Runner Status

- Online
- Connected
- Listening for Jobs

## Screenshot

<img width="1920" height="978" alt="Screenshot 2026-07-15 204202" src="https://github.com/user-attachments/assets/a29fde49-8228-4637-b380-4287600134ca" />


---

# Task 4 - Execute Workflow on Self-hosted Runner

Created a workflow that runs on the EC2 self-hosted runner.

Workflow performs:

- Show hostname
- Show working directory
- Create a file
- Verify file creation

Runner executed the job successfully.

## Runner Terminal

![Runner Terminal](04-runner-terminal.png)

---

## Verify File Creation

Confirmed that the workflow created the file successfully inside the runner workspace.

Command used:

```bash
find ~/actions-runner -name self-hosted-test.txt
```

Output:

```text
Hello from my self-hosted runner!
```

## Screenshot

<img width="1920" height="1006" alt="Screenshot 2026-07-15 204752" src="https://github.com/user-attachments/assets/86e9c48d-a5b4-4110-910d-ed71335f7a14" />


---

# Task 5 - Custom Runner Labels

Added a custom runner label.

```
my-linux-runner
```

Updated workflow:

```yaml
runs-on:
  - self-hosted
  - my-linux-runner
```

Workflow successfully executed using the custom label.

## Screenshot

<img width="1917" height="1025" alt="Screenshot 2026-07-15 210228" src="https://github.com/user-attachments/assets/cdf854e9-8c3d-4a3a-92fe-2352dfefc067" />


---

# GitHub Hosted vs Self Hosted Runner

| Feature | GitHub Hosted | Self Hosted |
|----------|---------------|-------------|
| Managed By | GitHub | User |
| Infrastructure | GitHub | User |
| Cost | GitHub Minutes | EC2 / Own Server |
| Pre-installed Tools | Yes | Manual |
| Maintenance | GitHub | User |
| Custom Software | Limited | Full Control |
| Best Use Case | CI/CD | Deployment & Private Infrastructure |

---

# What I Learned

- What GitHub Actions runners are
- Difference between GitHub-hosted and Self-hosted runners
- How to configure a Self-hosted Runner on AWS EC2
- How GitHub communicates with a runner
- How to execute workflows on EC2
- How to use custom labels
- How to verify workflow execution
- How to create files from GitHub Actions

---

# Repository Structure

```
.github/
└── workflows/
    ├── github-hosted.yml
    ├── tools.yml
    └── self-hosted.yml
```

---

# Conclusion

Today I learned how GitHub Actions runners work by configuring a Self-hosted Runner on an AWS EC2 instance, executing workflows on my own infrastructure, exploring GitHub-hosted runners, and using custom labels to target specific runners.

---

## Tech Stack

- GitHub Actions
- GitHub Hosted Runner
- Self-hosted Runner
- AWS EC2
- Ubuntu
- YAML
- Linux

---

#90DaysOfDevOps #GitHubActions #AWS #DevOps #SelfHostedRunner #CI #CD
