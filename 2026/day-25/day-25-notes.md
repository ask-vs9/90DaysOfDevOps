# Day 25 – Git Reset vs Revert & Branching Strategies

## Task 1: Git Reset Answers
- **The Differences:**
  - `--soft`: Moves the branch pointer backward, but leaves your files modified and already staged (green).
  - `--mixed` (Default): Moves the pointer backward and unstages your changes, leaving them in your working directory (red).
  - `--hard`: Moves the pointer backward and completely deletes all modifications from both the staging area and your working directory.
- **Destructive Mode:** `--hard` is highly destructive because it permanently overwrites uncommitted local modifications.
- **When to Use:** Use `--soft` when you want to rewrite the last commit message or squash a commit locally; use `--mixed` to unstage a massive file added by accident; use `--hard` when your local work is a complete dead-end and you want to start over from the last clean save.
- **Shared Branches Rule:** Never use `git reset` on commits that have already been pushed to a public/shared branch. It alters the commit timeline and breaks tracking states for everyone else.

## Task 2: Git Revert Answers
- **Reset vs Revert:** `git reset` deletes or alters history by moving the timeline pointers backward. `git revert` leaves the history intact and creates a completely brand-new commit that applies the exact opposite changes of the target commit.
- **Safety:** Revert is safe for shared branches because it only moves the history forward, meaning nobody else on your team will experience tracking synchronization issues.
- **When to Use:** Use `git reset` for private, local cleanup before pushing. Use `git revert` for production bugs or public shared branches.

## Task 3: Reset vs Revert Summary Matrix

| Feature | `git reset` | `git revert` |
| :--- | :--- | :--- |
| **What it does** | Moves the branch pointer back in history | Appends a new commit with inverse changes |
| **Removes commit from history?** | Yes | No |
| **Safe for shared branches?** | No | Yes |
| **When to use** | Local, unpushed cleanups | Public, pushed bug fixes |

## Task 4: Branching Strategies

### 1. GitFlow
- **How it works:** A strict, structured strategy utilizing permanent `master` and `develop` branches, alongside temporary `feature/*`, `release/*`, and `hotfix/*` branches.
- **Flow:** `develop` -> `release/*` -> `master`
- **When used:** Enterprise systems with long-standing scheduled production releases.
- **Pros/Cons:** Highly secure and organized; however, it is slow and can introduce painful merge conflicts.

### 2. GitHub Flow
- **How it works:** A lightweight layout where everything branches directly off `master`. Features are worked on, reviewed via Pull Requests, and merged back to master immediately.
- **Flow:** `master` -> `feature-branch` -> Pull Request -> `master`
- **When used:** Startups, SaaS teams, and continuous deployment environments.
- **Pros/Cons:** Very fast, uncomplicated, and fits modern CI/CD patterns; however, master is vulnerable if test suites are weak.

### 3. Trunk-Based Development
- **How it works:** Developers commit small, incremental changes directly to a single core branch ("the trunk" or master) multiple times a day using short-lived feature branches.
- **Flow:** `master` -> `short-lived-branch (hours)` -> Merged back to `master`
- **When used:** Advanced tech companies with comprehensive automated testing setups.
- **Pros/Cons:** Eliminates merge hell and speeds up delivery; requires high discipline and flawless automated test suites.

### Strategy Recommendations
- **Fast-shipping Startup:** GitHub Flow is best because it lacks process overhead and enables fast feature deployment.
- **Large Team with Scheduled Releases:** GitFlow provides the isolation and testing guards necessary to match slow, deliberate release cycles safely.
- **Open-Source Standard:** Most major modern open-source web ecosystems (like **React**) heavily utilize variants of **GitHub Flow** to review community contributions through Pull Requests.
