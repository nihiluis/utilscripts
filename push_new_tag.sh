#!/bin/bash

# push_new_tag.sh
# ------------------------------
# Description:
#   Automatically creates and pushes a new semantic version tag for Git repositories.
#   The script increments the patch version of the latest tag (e.g., v1.2.3 -> v1.2.4).
#   If no tags exist, it creates v0.0.1.
#
# Usage:
#   ./push_new_tag.sh [directory]     # Creates and pushes a new incremented tag
#   ./push_new_tag.sh -f [directory]  # Force updates the latest tag
#
# Examples:
#   ./push_new_tag.sh .               # Use current directory
#   ./push_new_tag.sh ..              # Use parent directory
#   ./push_new_tag.sh /path/to/repo   # Use specified repository path
#
# Requirements:
#   - Git repository must be clean (no uncommitted changes)
#
# ------------------------------

# Parse arguments
repo_path="."
force_flag=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            force_flag=true
            shift
            ;;
        *)
            repo_path="$1"
            shift
            ;;
    esac
done

# Verify and change to the specified directory
if ! cd "$repo_path" 2>/dev/null; then
    echo "Error: Unable to access directory: $repo_path"
    exit 1
fi

# Verify it's a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository: $repo_path"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "Error: There are uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [[ -z "$latest_tag" ]]; then
    echo "No existing tags found. Creating v0.0.1"
    new_tag="v0.0.1"
else
    echo "Latest tag: $latest_tag"

    if [[ "$force_flag" == "true" ]]; then
        # Force update the previous tag instead of creating a new one
        git tag -fa "$latest_tag" -m "Release $latest_tag"
        git push --force origin "$latest_tag"
        echo "Successfully force updated tag: $latest_tag"
        exit 0
    fi
    
    # Extract version numbers
    IFS='.' read -r major minor patch <<< "${latest_tag#v}"
    
    # Ensure we're reading the numbers as integers
    major=${major:-0}
    minor=${minor:-0}
    patch=${patch:-0}
    
    # Increment patch version
    new_patch=$((patch + 1))
    new_tag="v${major}.${minor}.${new_patch}"
    
    echo "Creating new tag: $new_tag"
fi

# Create and push the new tag
git tag -a "$new_tag" -m "Release $new_tag"
git push origin "$new_tag"
echo "Successfully created and pushed tag: $new_tag"
