# Day 24 Notes – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Task 1: Git Merge Responses
- **Fast-Forward Merge:** Occurs when the target branch (`master`) has not moved or diverged since the feature branch was created. Git simply pushes the pointer forward to the feature branch's head commit without creating a new merge commit.
- **Merge Commit:** Git creates a distinct merge commit when both branches have diverged with independent commits. This unique commit ties both parent timelines back together.
- **Merge Conflict:** A state where competing changes are made to the exact same line of code across different branches. Git stops automatic integration until the code is manually resolved and staged.

## Task 2: Git Rebase Responses
- **Rebase Function:** Rebase takes the unique commits from your current feature branch and replays them step-by-step on top of the newest tip of the target branch.
- **History Differences:** Merge retains a complex chronological web showing exactly where branches split and combined. Rebase produces a clean, perfectly linear straight-line timeline.
- **The Golden Rule:** Never rebase commits that have already been pushed and shared on public tracking repositories. Rewriting shared commit hashes breaks local tracking states for your team members.
- **Usage Strategy:** Use Merge to maintain full historical fidelity of feature lifecycles. Use Rebase to maintain a clean, readable master timeline before pushing features up.

## Task 3: Squash Commit vs Merge Commit
- **Squash Merging:** Condenses an entire cluster of feature development micro-commits (like typos or formatting adjustments) into a solitary unified commit block during the merge phase.
- **When to Use:** Ideal for tidying up local experimental branches before blending them into permanent main branches.
- **The Trade-off:** Keeps the tracking timeline incredibly clean, but strips out the deep, granular history of intermediate edits.

## Task 4: Git Stash Responses
- **Pop vs Apply:** `git stash pop` restores your uncommitted edits and promptly purges the tracking backup from memory. `git stash apply` restores your workspace files but leaves the backup record safely stored inside the stash register.
- **Real-world Workflow:** Essential when an unexpected, high-priority bug ticket appears while you are in the middle of a complex feature rollout and cannot commit half-baked code blocks.

## Task 5: Cherry Picking Responses
- **Cherry-Pick Definition:** Targets a single distinct commit hash from one branch and copies its exact logic snapshot onto your current checked-out branch.
- **Real Project Use Case:** Perfect for isolating a hotfix change built on an experimental branch and injecting it straight into production without pulling along incomplete features.
- **Risks:** Can cause duplicate commits or patch failures if the targeted code relies heavily on previous historical changes that were left behind.
