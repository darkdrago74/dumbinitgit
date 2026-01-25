#!/bin/bash

# -----------------------------------------------------------------------------
# dumbinitgit.sh - A git helper script
# -----------------------------------------------------------------------------
#
# This script helps with initializing a git repository and performing common
# git operations through a simple menu.
#
# USAGE:
# 1. Edit the variables in the 'CONFIGURATION' section below with your details.
# 2. Run the script: ./dumbinitgit.sh
#
# -----------------------------------------------------------------------------

# --- CONFIGURATION ---
# IMPORTANT: Fill these variables before the first run.
# After the first initialization, the script will replace these values for security.
# GITHUB_TOKEN, GITHUB_USERNAME, GITHUB_EMAIL, and REPO_URL must all be enclosed in double quotes. 
GITHUB_TOKEN="TOBEMODIFIED"
GITHUB_USERNAME="TOBEMODIFIED"
GITHUB_EMAIL="TOBEMODIFIED@mail.xyz"
REPO_URL="https://github.com/username/projectname.git"
INITIALIZED="false" # This will be set to "true" after the first successful init.

# --- SCRIPT LOGIC ---

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to initialize the repository
initialize_repo() {
    echo "--- Repository Initialization ---"

    # Check for git
    if ! command_exists git; then
        echo "Error: git is not installed. Please install git and try again."
        exit 1
    fi

    # Check if it's already a git repository
    if [ -d ".git" ]; then
        echo "This is already a git repository. Skipping initialization."
        # Mark as initialized to prevent asking again.
        sed -i 's/^INITIALIZED=.*/INITIALIZED="true"/' "$0"
        return
    fi

    # Validate configuration
    if [ "$GITHUB_TOKEN" = "TOBEMODIFIED" ] || [ "$GITHUB_USERNAME" = "TOBEMODIFIED" ] || [ "$GITHUB_EMAIL" = "TOBEMODIFIED" ]; then
        echo "Warning: Credentials are not set in the script."
        read -p "Do you want to enter them now? (y/n): " choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            read -p "Enter your GitHub Username: " GITHUB_USERNAME
            read -p "Enter your GitHub Email: " GITHUB_EMAIL
            read -s -p "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
            echo
        else
            echo "Initialization aborted. Please fill in the details in the script and run again."
            exit 1
        fi
    fi

    echo "Initializing git repository..."
    git init

    # Add this script to .gitignore to avoid committing it
    if ! grep -qxF "dumbinitgit.sh" .gitignore; then
        echo "Adding dumbinitgit.sh to .gitignore..."
        echo "dumbinitgit.sh" >> .gitignore
    fi

    git config user.name "$GITHUB_USERNAME"
    git config user.email "$GITHUB_EMAIL"
    
    echo "Adding remote origin..."
    git remote add origin "https://$GITHUB_TOKEN@$(echo $REPO_URL | sed 's|https://||')"
    
    echo "Initialization successful."

    # Add all files and make an initial commit
    git add .
    git commit -m "Initial commit"

    echo "Initial commit created."

    # Clean up sensitive information from the script itself
    echo "Securing script: removing credentials..."
    sed -i 's/^GITHUB_TOKEN=.*/GITHUB_TOKEN="AlreadyInit"/' "$0"
    sed -i 's/^GITHUB_USERNAME=.*/GITHUB_USERNAME="AlreadyInit"/' "$0"
    sed -i 's/^GITHUB_EMAIL=.*/GITHUB_EMAIL="AlreadyInit"/' "$0"
    sed -i 's/^INITIALIZED=.*/INITIALIZED="true"/' "$0"

    echo "Script secured. Credentials have been removed."
    echo "---------------------------------"
}

# --- MENU FOR GIT OPERATIONS ---

# Function to push changes
git_push() {
    echo "--- Push changes to GitHub ---"
    echo "This uploads your locally saved (committed) changes from your RPi to the GitHub project."
    echo "Example: After testing a change on your RPi, you use this to share it with the remote GitHub project."
    read -p "Enter the branch to push to (e.g., main): " branch
    if [ -z "$branch" ]; then
        echo "Branch name cannot be empty."
        return
    fi
    git push origin "$branch"
}

# Function to commit changes
git_commit() {
    echo "--- Commit (save) changes locally ---"
    echo "This saves a snapshot of your current changes on your RPi. Think of it as creating a local save point."
    echo -e "\033[1;33mImportant: After you commit, you must use 'Push' to upload your local save to the GitHub project.\033[0m"
    read -p "Enter your commit message (e.g., 'Added new sensor reading code'): " msg
    if [ -z "$msg" ]; then
        echo "Commit message cannot be empty."
        return
    fi
    git add .
    git commit -m "$msg"
}

# Function to fetch changes
git_fetch() {
    echo "--- Fetch changes from GitHub ---"
    echo "This downloads the latest project history from the remote GitHub project to your local RPi, but doesn't change your files yet."
    echo "It's like checking for mail without opening it. 'Remote' is the GitHub project, 'local' is your RPi."
    git fetch --all
    echo "Branches available on remote:"
    git branch -r
}

# Function to pull (fetch and merge) changes
git_pull() {
    echo "--- Pull (update) from GitHub ---"
    echo "This downloads the latest changes from the GitHub project and automatically merges them into your current working files on your RPi."
    echo "Use this to get the latest version of the project from GitHub."
    read -p "Enter the branch to pull from (e.g., main): " branch
    if [ -z "$branch" ]; then
        echo "Branch name cannot be empty."
        return
    fi
    git pull origin "$branch"
}

# Function to list branches
list_branches() {
    echo "--- List all branches ---"
    echo "This shows all versions of the project, both locally on your RPi and remotely on the GitHub project."
    echo "Local branches:"
    git branch
    echo ""
    echo "Remote branches:"
    git branch -r
}

# Function to create a new branch
create_branch() {
    echo "--- Create a new branch ---"
    echo "Creates a new branch on your local RPi and switches to it. Branches let you work on new features without affecting the main version."
    read -p "Enter the name for the new branch: " branch
    if [ -z "$branch" ]; then
        echo "Branch name cannot be empty."
        return
    fi
    git checkout -b "$branch"
}

# Function to switch branch
switch_branch() {
    echo "--- Switch to a different branch ---"
    echo "This changes your active set of files to a different version (branch)."
    read -p "Enter the branch name to switch to: " branch
    if [ -z "$branch" ]; then
        echo "Branch name cannot be empty."
        return
    fi
    git checkout "$branch"
}

# Function to reset local changes
git_reset_hard() {
    echo "--- DANGEROUS: reset_hard ---"
    echo -e "\033[1;31mWARNING: This will permanently delete ALL local changes on your RPi that you have not pushed to the GitHub project.\033[0m"
    echo "It resets your local folder to be an exact copy of the GitHub project's branch."
    read -p "Are you absolutely sure you want to do this? (yes/no): " confirmation
    if [ "$confirmation" != "yes" ]; then
        echo "Reset cancelled."
        return
    fi
    read -p "Enter the branch on GitHub to reset to (e.g., main): " branch
    if [ -z "$branch" ]; then
        echo "Branch name cannot be empty."
        return
    fi
    git fetch origin # Make sure we have the latest info
    git reset --hard "origin/$branch"
    echo "Local folder has been reset."
}

# Main menu function
show_menu() {
    while true; do
        echo ""
        echo "--- DumbInitGit Menu ---"
        echo "Workflow: 1. Commit -> 2. Push"
        echo "-----------------------------------------------------"
        echo "1. Commit (save changes on your RPi)"
        echo "2. Push (upload your RPi's changes to GitHub project)"
        echo ""
        echo "3. Pull (update your RPi with the latest from GitHub project)"
        echo "4. Fetch (check for remote changes without merging)"
        echo ""
        echo "5. List Branches"
        echo "6. Create Branch"
        echo "7. Switch Branch"
        echo ""
        echo "8. DANGEROUS: reset_hard (Reset RPi folder to match GitHub)"
        echo "q. Quit"
        echo "--------------------"
        read -p "Choose an option: " choice

        case $choice in
            1) git_commit ;;
            2) git_push ;;
            3) git_pull ;;
            4) git_fetch ;;
            5) list_branches ;;
            6) create_branch ;;
            7) switch_branch ;;
            8) git_reset_hard ;;
            q) echo "Exiting dumbinitgit. Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# --- MAIN SCRIPT EXECUTION ---

# If not initialized, run initialization first.
if [ "$INITIALIZED" = "false" ]; then
    initialize_repo
fi

# Show the main menu
show_menu
