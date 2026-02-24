---
title: "initialize entire commit log"
date: 2022-04-15T22:33:52+09:00
lastmod: 2026-02-11T22:34:00+09:00
description: "How to delete (reset) all commit history when sensitive information or files are exposed in a public repository"
keywords: []
tags: ["git", "dev"]
---

## Overview

This guide shows how to delete (reset) the entire commit history of a repository.

If sensitive data like images, IDs, or passwords are exposed in your public repository, you can use this method to wipe all commit history and stay safe.

## Background

### How it works

The idea behind resetting commit history is simple.

![Architecture](./1.png)

1. Create a new branch called latest_branch from main.
2. Delete the old main branch.
3. When the old main branch is deleted, all commit logs inside it are also deleted.
4. Rename latest_branch to main.
5. Push the new main branch to the remote.

You must run these steps in a local clone of the repository.

### Warnings

#### Commit log deletion

- Following this guide will erase all commit history on the main branch. There is no way to recover deleted commit logs.

### Limitation

This limitation only applies to public repositories. Even after deleting all commits, the [Activity](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/using-the-activity-view-to-see-changes-to-a-repository) records remain on GitHub. Anyone can still view the diff of each commit through Activity records.

- [According to GitHub Support](https://webapps.stackexchange.com/a/82920), public activity is not deleted unless sensitive information is exposed. This is a policy to keep repository transparency and change history. However, GitHub's Secret Scanning feature is enabled by default, so pushes containing secret keys or tokens are rejected. Secret Scanning helps a lot, but you still need to stay careful.
- There is a feature request to restrict Activity visibility to specific people at [Repository Activity View #53140](https://github.com/orgs/community/discussions/53140#discussioncomment-6052248).

## Prerequisites

You need git installed on your local machine.

```bash
$ git --version
git version 2.37.1 (Apple Git-137.1)
```

## Solution

There are two ways to reset commit history:

- Using git commands manually
- Running a pre-built script

### Using git commands

#### Checkout

Create a new branch called latest_branch.

```bash
# [>] main
git checkout --orphan latest_branch
```

The checkout --orphan command creates a new branch with no commit history.

#### Add all files

Add all files to the new latest_branch branch.

```bash
# [ ] main
# [>] latest_branch
git add -A
```

The -A flag stages all files.

```bash
# [ ] main
# [>] latest_branch
git commit \
  -m "Initial commit" \
  -m "Initialize repository to clean all commit history using commit history cleaner script"
```

Commit all files to the new latest_branch branch.

#### Delete branch

Delete the old main branch.

```bash
# [X] main
# [>] latest_branch
git branch -D main
```

When the old main branch is deleted, all its commit logs are deleted too.

#### Rename branch

Rename latest_branch to main.

```bash
# [>] latest_branch --> main
git branch -m main
```

The -m flag renames the branch.

#### Force push

```bash
# [>] main
git push -f origin main
```

Force push the new main branch to the remote.

#### Verify

Check the commit log on the new main branch.

```bash
# [>] main
git log --graph

# Display commit history as a one-line summary with a graph
git log --oneline --graph
```

The --graph flag shows the commit log as a tree.

The output looks like this:

```bash
* commit 4xxx81728xx4x8815f6970f43545b3xxx433x2x3 (HEAD -> main, origin/main, origin/HEAD)
  Author: younsl <cysl@kakao.com>
  Date:   Fri Feb 24 17:33:33 2023 +0900

      Initial commit
```

All previous commit logs are gone. Only the initial commit remains.

No one can see the exposed sensitive information in commit logs anymore.

Commit history reset is complete.

### Using a script

First, navigate to the git directory where you want to reset commit history.

Download the [commit history cleaner script](https://github.com/younsl/dotfiles/blob/main/scripts/git/commit-history-cleaner.sh) from GitHub.

```bash
wget -O commit-history-cleaner.sh \
  https://raw.githubusercontent.com/younsl/dotfiles/refs/heads/main/scripts/git/commit-history-cleaner.sh
```

Check the downloaded file.

```bash
ls -lh commit-history-cleaner.sh
```

```bash
-rw-r--r--@ 1 john.doe  staff   1.7K Feb  4 04:33 commit-history-cleaner.sh
```

Run the script.

```bash
sh commit-history-cleaner.sh
```

The script asks for confirmation. Type y to delete all commit logs on the main branch.

> **Warning**: This is a destructive operation that deletes all commit logs on the main branch. You cannot undo this.

```bash
This script will delete the main branch and create the latest_branch branch.
Do you want to continue? (yY/n) y
```

Verify the result.

```bash
# Display commit history as a one-line summary with a graph
git log --oneline --graph
```

Commit history reset is complete.

## Conclusion

Do not use rm -rf .git to delete the .git directory. It contains submodule settings and other repository configs. Deleting it is risky and hard to recover from.

The goal is to wipe commit history, not the entire repository setup. A much simpler and safer approach is to copy main to a new branch, delete the old main, and rename the new branch. Remember: when a branch is deleted, all commit logs inside it are deleted too.

## References

**Github**:

- [Commit history cleaner script](https://github.com/younsl/dotfiles/blob/main/scripts/git/commit-history-cleaner.sh)
- [Repository Activity View #53140](https://github.com/orgs/community/discussions/53140)
