#!/bin/bash

check_command_exists() {
    local command=$1

    if ! command -v "$command" &> /dev/null; then
        echo "Error: '$command' command is not installed."
        exit 1
    fi
}

delete_and_create_branch() {
    local branch_name="latest_branch"
    local base_branch="main"

    echo "This script will delete the ${base_branch} branch and create the ${branch_name} branch."
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi

    check_command_exists "git"

    git checkout --orphan "$branch_name"
    git add -A
    git commit -am "kickoff: Initial commit"

    git branch -D "$base_branch" || true
    git branch -m "$base_branch"
    git push -f origin "$base_branch"
    git branch --set-upstream-to=origin/$base_branch

    echo "Done."
}

delete_and_create_branch
