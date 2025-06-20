#!/usr/bin/bash


# install base packages
dnf copr enable atim/starship -y
dnf install -y zsh \
                zoxide \
                fastfetch \
                util-linux \
                starship \
                tmux \
                vim \
                git \
                git-delta


# set zsh as default shell
if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s $(which zsh)
fi

# set zshrc
cp .zshrc ~/.zshrc
mkdir -p ~/.config


# config git
cp .gitconfig ~/.gitconfig

# config tmux
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf ~/.tmux.conf

# config starship
cp .config/starship.toml ~/.config/starship.toml

# install docker
dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
dnf update ca-certificates -y
dnf -y install dnf-plugins-core

dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

systemctl enable --now docker
