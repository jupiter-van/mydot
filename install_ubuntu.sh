#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

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
    git-delta \
    fzf \
    ca-certificates \
    curl

# 设置 zsh 为默认 shell
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
fi

# 设置 zshrc
cp .zshrc ~/.zshrc
mkdir -p ~/.config ~/.config/fzf

# fzf-git 辅助脚本（.zshrc 会 source）
if [ ! -f ~/.config/fzf/fzf-git.sh ]; then
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh \
        -o ~/.config/fzf/fzf-git.sh
fi

# 配置 git
cp .gitconfig ~/.gitconfig

# 配置 tmux
mkdir -p ~/.tmux/plugins
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
cp .tmux.conf ~/.tmux.conf
export TMUX_PLUGIN_MANAGER_PATH="${HOME}/.tmux/plugins/"
~/.tmux/plugins/tpm/bin/install_plugins || true

# 配置 starship
cp .config/starship.toml ~/.config/starship.toml

# 卸载 Ubuntu 发行版 / 冲突的 Docker 包，改用 Docker 官方社区版 (CE)
# https://docs.docker.com/engine/install/ubuntu/
for pkg in docker.io docker-doc docker-compose docker-compose-v2 docker-buildx \
           podman-docker containerd runc docker docker-engine; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt-get remove -y "$pkg"
    fi
done

sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 去掉旧的 one-line list，改用官方 deb822 源
sudo rm -f /etc/apt/sources.list.d/docker.list

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"