#!/usr/bin/env zsh
# ============================================================================
# Flatpak Package Manager Installation Functions
# ============================================================================

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    MODULE_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
source "${MODULE_DIR}/helpers/check-install.zsh"

# ============================================================================
# Flatpak Repository Setup
# ============================================================================

setup_flatpak_repo() {
    print_section "Setting up Flatpak Repository"
    
    if ! command -v flatpak &> /dev/null; then
        log_warning "Flatpak is not installed. Skipping Flatpak installations."
        return 1
    fi
    
    log_info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || {
        log_error "Failed to add Flathub repository"
        return 1
    }
    
    log_success "Flatpak repository configured!"
    return 0
}

# ============================================================================
# Category: Productivity Applications
# ============================================================================

install_productivity_flatpaks() {
    print_section "Installing Productivity Applications (Flatpak)"
    
    local packages=("md.obsidian.Obsidian")
    
    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        flatpak install flathub -y "$package" || log_error "Failed to install $package"
    done
}

# ============================================================================
# Main Flatpak Installation Function
# ============================================================================

install_flatpak_all() {
    print_section "Starting Flatpak Installations"
    
    if ! setup_flatpak_repo; then
        log_error "Flatpak setup failed. Aborting Flatpak installations."
        return 1
    fi
    
    install_productivity_flatpaks
    
    log_success "All Flatpak installations completed!"
    return 0
}