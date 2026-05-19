if ! command -v zsh &> /dev/null; then
    sudo dnf install -y zsh
fi

chsh -s $(which zsh) $USER