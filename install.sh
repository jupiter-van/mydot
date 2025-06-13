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
