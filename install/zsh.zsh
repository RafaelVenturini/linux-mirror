#!/usr/bin/env zsh
# ============================================================================
# Zsh Shell Installation and Configuration
# ============================================================================

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    MODULE_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
source "${MODULE_DIR}/helpers/check-install.zsh"

# ============================================================================
# Zsh Installation
# ============================================================================

install_zsh() {
    print_section "Installing Zsh Shell"
    
    if check_install "zsh" "Zsh"; then
        log_info "Zsh is already installed"
        return 0
    fi
    
    log_info "Installing Zsh..."
    if execute_cmd "sudo dnf install -y zsh" "Failed to install Zsh"; then
        log_success "Zsh installation completed!"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Zsh Configuration
# ============================================================================

configure_zsh() {
    print_section "Configuring Zsh as Default Shell"
    
    local zsh_path
    zsh_path=$(which zsh)
    
    if [[ -z "$zsh_path" ]]; then
        log_error "Zsh executable not found"
        return 1
    fi
    
    log_info "Setting Zsh as default shell for user $USER..."
    
    if execute_cmd "chsh -s \"$zsh_path\" \"$USER\"" \
        "Failed to set Zsh as default shell"; then
        log_success "Zsh configured as default shell!"
        log_warning "You may need to restart your terminal or log out and log back in for changes to take effect."
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Main Zsh Installation and Configuration Function
# ============================================================================

install_zsh_all() {
    print_section "Starting Zsh Setup"
    
    if ! install_zsh; then
        log_error "Zsh installation failed"
        return 1
    fi
    
    if ! configure_zsh; then
        log_error "Zsh configuration failed"
        return 1
    fi
    
    log_success "Zsh setup completed successfully!"
    return 0
}