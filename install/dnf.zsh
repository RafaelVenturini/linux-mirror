#!/usr/bin/env zsh
# ============================================================================
# DNF Package Manager Installation Functions
# ============================================================================

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    MODULE_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
source "${MODULE_DIR}/helpers/check-install.zsh"

# ============================================================================
# Category: AI & Machine Learning
# ============================================================================

install_ai_packages() {
    print_section "Installing AI & ML Packages (DNF)"
    
    local packages=("ollama")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo dnf install -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Category: CLI Tools & Utilities
# ============================================================================

install_cli_packages() {
    print_section "Installing CLI Tools & Utilities (DNF)"
    
    local packages=("btop" "fastfetch" "bat" "curl" "flatpak" "fzf" "ripgrep" "kitty")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo dnf install -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Category: Design & Graphics
# ============================================================================

install_design_packages() {
    print_section "Installing Design Tools (DNF)"
    
    local packages=("krita")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo dnf install -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Category: Development Tools
# ============================================================================

install_dev_packages() {
    print_section "Installing Development Tools (DNF)"
    
    local packages=("git" "docker" "python3" "nodejs" "golang" "nodejs-npm" "neovim")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo dnf install -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Category: File Management & Cloud Sync
# ============================================================================

install_file_packages() {
    print_section "Installing File Management Tools (DNF)"
    
    local packages=("rclone" "fontconfig")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo dnf install -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Main DNF Installation Function
# ============================================================================

install_dnf_all() {
    print_section "Starting DNF Installations"
    
    install_ai_packages
    install_cli_packages
    install_design_packages
    install_dev_packages
    install_file_packages
    
    log_success "All DNF installations completed!"
}
