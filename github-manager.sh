#!/bin/bash

##########################################
# just for me comment   #
#   git config --global user.name "ziyad-tarek1"
#   git config --global user.email "ziyadtarek180@gmail.com"
##########################################

##########################################
# GitHub Repository Management Script   #
##########################################

# This script allows users to interact with GitHub repositories, including:
# - Using existing repositories
# - Creating new repositories
# - Deleting existing repositories

# Set global Git configurations for user name and email using variables
GITHUB_USER="ziyad-tarek1"
GITHUB_EMAIL="ziyadtarek180@gmail.com"
git config --global user.name "$GITHUB_USER"
git config --global user.email "$GITHUB_EMAIL"

# Function to handle git operations
commit_and_push() {
    # Add specified file or folder to the Git staging area
    git add .
    # Commit changes with an automated message mentioning the changed file or folder
    git commit -m "Automated commit for changes in $1"
    # Pull changes from the remote main branch, incorporating them via rebase
    git pull --rebase origin main
    # Push committed changes to the remote main branch
    git push origin main
}

# Function to delete repository
delete_repository() {
    # Interactive confirmation prompt for repository deletion
    read -p "Are you sure you want to delete the repository '$1'? This action cannot be undone. (yes/no): " confirm
    case "$confirm" in
        yes|YES|y|Y)
            # Use GitHub CLI to delete the specified repository with confirmation
            gh repo delete "$1" --yes
            # Check if the deletion was successful
            if [ $? -eq 0 ]; then
                echo "Repository $1 deleted successfully."
            else
                echo "Error: Failed to delete repository $1."
                exit 1
            fi
            ;;
        no|NO|n|N)
            echo "Repository deletion aborted."
            ;;
        *)
            echo "Invalid input. Aborting repository deletion."
            ;;
    esac
}

# Prompt for repository action
echo "Choose an option:"
echo "1) Use an existing repository"
echo "2) Create a new repository"
echo "3) Delete an existing repository"
read -p "Enter your choice (1, 2, or 3): " choice


# Read repository name and file or folder to push for options 1 and 2
read -p "Enter the repository name: " REPO_NAME
read -p "Enter the file or folder to push to GitHub: " FILE_OR_FOLDER
# Prompt for GitHub Personal Access Token (PAT) for authentication
read -s -p "Enter your GitHub Personal Access Token: " GITHUB_PAT
export GITHUB_TOKEN="$GITHUB_PAT"

# Validate the user's choice
if [ "$choice" != "1" ] && [ "$choice" != "2" ] && [ "$choice" != "3" ]; then
    echo "Invalid choice. Exiting..."
    exit 2
fi

# Handle user's choice
if [ "$choice" -eq 1 ]; then
    # Use an existing repository
    if [ ! -d "$REPO_NAME" ]; then
        # Clone the repository from GitHub using SSH
        git clone git@github.com:$GITHUB_USER/$REPO_NAME.git
        # Check if cloning was successful
        if [ $? -ne 0 ]; then
            echo "Error: Failed to clone repository. Exiting..."
            exit 1
        fi
        cd "$REPO_NAME"
    else
        cd "$REPO_NAME"
    fi

    # Add, commit, and push changes
    if [ ! -e "$FILE_OR_FOLDER" ]; then
        echo "Error: File or folder '$FILE_OR_FOLDER' does not exist."
        exit 1
    fi
    commit_and_push "$FILE_OR_FOLDER"
elif [ "$choice" -eq 2 ]; then
    # Create a new repository
    # Check if the specified repository name already exists
    EXISTING_REPO=$(curl -s "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME")
    # If repository exists, exit with an error message
    if [[ $EXISTING_REPO != *"Not Found"* ]]; then
        echo "Error: Repository name '$REPO_NAME' already exists. Exiting..."
        exit 1
    fi



    # Create a new repository on GitHub
    gh repo create "$REPO_NAME" --public

    # Initialize Git repository, add file or folder, and push to GitHub
    mkdir "$REPO_NAME"
    cd "$REPO_NAME"
    git init
    cp -r "../$FILE_OR_FOLDER" .  # Adjusted the command to copy recursively
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin git@github.com:$GITHUB_USER/$REPO_NAME.git
    git push -u origin main
elif [ "$choice" -eq 3 ]; then
    # Delete an existing repository
    read -p "Enter the name of the repository to delete: " REPO_NAME
    delete_repository "$REPO_NAME"
fi

echo "Operation completed successfully!"
