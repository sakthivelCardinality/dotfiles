#!/usr/bin/env bash

ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/tmux/session-manager.sh ~/session-manager.sh
ln -sf ~/dotfiles/tmux/session-manager.sh ~/.local/bin/t
ln -sf ~/dotfiles/config/.user_alias ~/.user_alias
ln -sf ~/dotfiles/config/.user_config ~/.user_config

# setup default global gitconfig
# chmod +x ./config/gitconfig.sh
# ./config/gitconfig.sh
