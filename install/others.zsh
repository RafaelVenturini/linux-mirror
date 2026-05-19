#!/usr/bin/env zsh
# ============================================================================
# Custom Installation Functions for Specialized Tools
# ============================================================================

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    MODULE_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
source "${MODULE_DIR}/helpers/check-install.zsh"

# ============================================================================
# Superfile (spf) Installation
# ============================================================================

install_superfile() {
    print_section "Installing Superfile (spf)"
    
    if check_install "spf" "Superfile (spf)"; then
        return 0
    fi
    
    log_info "Downloading and installing Superfile..."
    
    if execute_cmd 'bash -c "$(curl -sLo- https://superfile.dev/install.sh)"' \
        "Failed to install Superfile"; then
        log_success "Superfile installation completed!"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Visual Studio Code Installation
# ============================================================================

install_vscode() {
    print_section "Installing Visual Studio Code"
    
    if check_install "code" "Visual Studio Code"; then
        return 0
    fi
    
    log_info "Setting up Microsoft repository..."
    
    if ! execute_cmd "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc" \
        "Failed to import Microsoft GPG key"; then
        return 1
    fi
    
    log_info "Adding VS Code repository..."
    local repo_config="[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc"
    
    if ! echo -e "$repo_config" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null; then
        log_error "Failed to add VS Code repository"
        return 1
    fi
    
    log_info "Installing VS Code..."
    if execute_cmd "sudo dnf install -y code" "Failed to install VS Code"; then
        log_success "Visual Studio Code installation completed!"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Main Custom Installation Function
# ============================================================================

install_others_all() {
    print_section "Starting Custom Tool Installations"
    
    install_superfile || log_warning "Superfile installation failed or was skipped"
    install_vscode || log_warning "VS Code installation failed or was skipped"
    
    log_success "Custom tool installations completed!"
}
