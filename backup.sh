#!/bin/bash

SOURCE_DIR="/home/ubuntu/nikhil"     
TARGET_DIR="/home/ubuntu/backuper/nikhil-backup"    
NEW_REPO_URL="https://github.com/Nikhil690/vms-backup.git" 

if [ -d "$TARGET_DIR" ]; then
    echo "Target directory exists. Syncing $SOURCE_DIR to $TARGET_DIR..."
    rsync -av "$SOURCE_DIR/" "$TARGET_DIR/" &>/dev/null
else
    echo "Target directory does not exist. Creating it and copying files..."
    cp -r "$SOURCE_DIR" "$TARGET_DIR"
fi

echo "Removing all .git directories to flatten the structure..."
find "$TARGET_DIR/." -mindepth 2 -type d -name ".git" -exec rm -rf {} +

echo "Setting up Git repository in the backup directory..."
cd "$TARGET_DIR"
ls -al
if [ ! -d .git ]; then
    echo ".git does not exist. Initializing..."
    git init
    git remote add origin "$NEW_REPO_URL"
else
    echo ".git alreay exists" 
fi

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "Adding all files to the backup repository and committing any changes..."
git add .
git commit -m "Backup on $TIMESTAMP" || echo "No changes to commit."

echo "Pushing the backup to GitHub..."
if ! command -v git branch -r | grep origin/main  &> /dev/null; then
    echo "The main branch exists."
    git push origin main
else
    echo "The main branch does not exist."
    git branch -M main
    git push origin main
fi

echo "Backup completed and pushed to $NEW_REPO_URL"
