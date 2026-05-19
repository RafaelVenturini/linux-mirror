echo "Installing packages with DNF..."

# =============     IA     ============= #
sudo dnf install -y ollama

# =============     CLI    ============= #
sudo dnf install -y btop fastfetch bat fzf ripgrep kitty

# =============   DESIGN   ============= #
sudo dnf install -y krita

# =============     DEV    ============= #
sudo dnf install -y git docker python3 nodejs golang nodejs-npm neovim

# =============   FILES    ============= #
sudo dnf install -y rclone

echo "DNF installation completed!"
