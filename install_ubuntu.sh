#!/usr/bin/env bash

# 安装基础软件包
sudo apt update
sudo apt install -y \
    zsh \
    zoxide \
    fastfetch \
    util-linux \
    starship \
    tmux \
    vim \
    git \
    delta

# 设置 zsh 为默认 shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
fi

# 设置 zshrc
cp .zshrc ~/.zshrc
mkdir -p ~/.config

# 配置 git
cp .gitconfig ~/.gitconfig

# 配置 tmux
mkdir -p ~/.tmux/plugins
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
cp .tmux.conf ~/.tmux.conf

# 配置 starship
cp .config/starship.toml ~/.config/starship.toml

# 安装 Docker
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker