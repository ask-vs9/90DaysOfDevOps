# Day 22 Notes

## 1. Difference between git add and git commit

git add moves changes to the staging area.
git commit saves staged changes permanently into repository history.

---

## 2. What does staging area do?

The staging area lets developers choose which changes should be included in the next commit.
It helps create clean and organized commits instead of committing everything directly.

---

## 3. What information does git log show?

git log shows:
- commit ID
- author
- date
- commit message

It displays repository history.

---

## 4. What is .git folder?

.git is the internal database of Git.
It stores commits, branches, configurations, and repository history.

If deleted, the project is no longer a Git repository and history is lost.

---

## 5. Difference between working directory, staging area, and repository

Working Directory:
Current files being edited.

Staging Area:
Temporary area where selected changes are prepared for commit.

Repository:
Permanent Git history containing committed snapshots.
