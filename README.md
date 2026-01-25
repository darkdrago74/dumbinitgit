# dumbinitgit.sh - A Git Helper Script

This script provides a simple, menu-driven interface to perform common Git operations. It is designed to simplify the process of initializing a Git repository, committing changes, and synchronizing with a remote repository on GitHub.

## Prerequisites

Before using this script, you must have `git` installed on your system.
```bash
sudo apt-get install -y git
git clone https://github.com/darkdrago74/dumbinitgit.git
```

## Configuration

Before running the script for the first time, you need to edit the `CONFIGURATION` section within the `dumbinitgit.sh` file:

```bash
# --- CONFIGURATION ---
# IMPORTANT: Fill these variables before the first run.
# After the first initialization, the script will replace these values for security.
# GITHUB_TOKEN, GITHUB_USERNAME, GITHUB_EMAIL, and REPO_URL must all be enclosed in double quotes. 
GITHUB_TOKEN="TOBEMODIFIED"
GITHUB_USERNAME="TOBEMODIFIED"
GITHUB_EMAIL="TOBEMODIFIED@mail.xyz"
REPO_URL="https://github.com/username/projectname.git"
INITIALIZED="false" # This will be set to "true" after the first successful init.
```

1.  **`GITHUB_TOKEN`**: Your GitHub Personal Access Token. This is used to authenticate with GitHub.
2.  **`GITHUB_USERNAME`**: Your GitHub username.
3.  **`GITHUB_EMAIL`**: The email address associated with your GitHub account.
4.  **`REPO_URL`**: The URL of the remote repository you want to link to (e.g., `https://github.com/your-username/your-repo.git`).

**Note:** For security, the script will remove these credentials from itself after the initial repository setup.

## Usage

1.  **Make the script executable:**
    ```bash
    chmod +x dumbinitgit.sh
    ```

2.  **Run the script:**
    ```bash
    ./dumbinitgit.sh
    ```

### First Run (Initialization)

The first time you run the script in a directory that is not a Git repository, it will:
1.  Initialize a new Git repository.
2.  Configure your local Git user name and email.
3.  Add a remote named `origin` using the `REPO_URL` and your `GITHUB_TOKEN`.
4.  Create an initial commit with all existing files.
5.  Add `dumbinitgit.sh` to a `.gitignore` file to prevent it from being committed.
6.  Remove the sensitive credential values from the script file itself.

If the script is run in a directory that is already a Git repository, it will skip the initialization steps.

### Git Operations Menu

After initialization, the script displays a menu with the following options:

*   **1. Commit (save changes on your RPi)**: Saves a snapshot of your current changes locally. You will be prompted for a commit message.
*   **2. Push (upload your RPi's changes to GitHub project)**: Uploads your committed changes to the remote GitHub repository. You will be prompted for the branch name.
*   **3. Pull (update your RPi with the latest from GitHub project)**: Downloads and merges the latest changes from the remote repository into your current branch.
*   **4. Fetch (check for remote changes without merging)**: Downloads the latest history from the remote repository without changing your files.
*   **5. List Branches**: Shows all local and remote branches.
*   **6. Create Branch**: Creates a new local branch and switches to it.
*   **7. Switch Branch**: Switches to a different existing local branch.
*   **8. DANGEROUS: reset_hard (Reset RPi folder to match GitHub)**: This is a dangerous option that will discard all your local changes and reset your current branch to match the state of the remote branch. Use with extreme caution.
*   **q. Quit**: Exits the script.

#Note to myself to install Gemini on a RPi
install nodejs 24 (64bit OS bookworm or trixie) or nodejs20 for 32bit OS on the RPi (replace 24.x by 20.x in the next command line)
```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash - && sudo apt-get install -y nodejs
```
Then Gemini install with npm
```bash
sudo npm install -g @google/gemini-cli
```
