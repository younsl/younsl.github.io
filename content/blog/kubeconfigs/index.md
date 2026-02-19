---
title: "kubeconfigs"
date: 2026-02-17T23:00:00+09:00
description: "Why I switched from kubectx/kubens to kubeswitch for Kubernetes context management"
keywords: []
tags: ["kubernetes", "devops"]
---

## Tools

DevOps Engineers and SREs manage a lot of [Kubernetes](https://kubernetes.io) clusters. Sandbox, dev, staging, production. Multiply by teams or regions, and you end up with dozens of contexts. Switching between them quickly and safely is part of the daily workflow.

### kubectl

[kubectl](https://github.com/kubernetes/kubectl) has a built-in interface: kubectl config get-contexts, kubectl config use-context. Too much to type, hard to find the right context, and global to your user.

### kubectx

[kubectx](https://github.com/ahmetb/kubectx) improved this with fuzzy searching via [fzf](https://github.com/junegunn/fzf). [kubens](https://github.com/ahmetb/kubectx) came alongside it for namespace switching. But both are still global. They directly modify current-context in ~/.kube/config. Switch to prd in terminal A, and terminal B silently points to prd too.

### kubeswitch

[kubeswitch](https://github.com/danielfoehrKn/kubeswitch) solves the isolation problem by creating temporary kubeconfig files per session through shell functions. It also replaces both kubectx and kubens: switch for contexts, switch ns for namespaces.

### kubie

[kubie](https://github.com/sbstp/kubie) takes a different approach. Instead of shell functions, it spawns a new subshell with the right KUBECONFIG set. Simpler setup, but the subshell breaks zsh history sharing between sessions. Also, the original maintainer [stopped actively maintaining the project](https://github.com/sbstp/kubie/issues/385) since 2020 and is looking for new maintainers, which raises long-term sustainability concerns.

So, these days, I just use kubeswitch. I uninstalled kubectx and kubens from both Homebrew and krew.

## Setup

kubeswitch setup guide for macOS with zsh.

Install with [Homebrew](https://brew.sh).

```bash
brew install danielfoehrkn/switch/switch
```

Add shell integration to ~/.zshrc.

```bash
tee -a ~/.zshrc << 'EOF'
source <(switcher init zsh)
source <(switcher completion zsh)
compdef _switcher switch
alias s=switch
EOF
```

switcher is the Go binary installed by Homebrew. switch is a shell function created by switcher init zsh. The shell function calls switcher internally and applies the returned KUBECONFIG path to the current session's environment. A binary cannot modify the parent shell's environment variable, so the shell function is what makes per-session isolation possible.

Without compdef _switcher switch, tab completion does not work for the switch command. The completion is registered for the switcher binary, but switch is a shell function, so it needs to be explicitly connected.

## Usage

```bash
switch                   # Select context with fuzzy search
switch set-context dev   # Switch to a specific context
switch ns                # Select namespace with fuzzy search
s                        # Alias for switch
```

`switch` is for switching between Kubernetes contexts (clusters). `switch ns` is for switching between namespaces within the current context.
