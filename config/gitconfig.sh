#!/usr/bin/env bash

echo "git config --global rerere.enabled true"
git config --global rerere.enabled true

echo "git config --global cloumn.ui auto"
git config --global cloumn.ui auto

echo "git config --global branch.sort committerdate"
git config --global branch.sort committerdate

# echo "git config --global core.fsmonitor true"
# git config --global core.fsmonitor true

# Run the below command in the git project.
# this will run cronjob in the project dir 
# which will run garbage collection in the background which will run at the time of git commint
# git maintenance start 
