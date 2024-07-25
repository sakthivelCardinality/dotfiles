#!/usr/bin/env bash

echo "git config --global rerere.enabled true"
git config --global rerere.enabled true

echo "git config --global cloumn.ui auto"
git config --global cloumn.ui auto

echo "git config --global branch.sort committerdate"
git config --global branch.sort committerdate

echo "squash-all alias created for the git"
# git squash-all -m "a brand new start"
git config --global alias.squash-all '!f(){ git reset $(git commit-tree HEAD^{tree} "$@");};f'

echo "git config --global push.autoSetupRemote true"
git config --global push.autoSetupRemote true

# echo "git config --global core.fsmonitor true"
# git config --global core.fsmonitor true

# Run the below command in the git project.
# this will run cronjob in the project dir
# which will run garbage collection in the background which will run at the time of git commint
# git maintenance start
