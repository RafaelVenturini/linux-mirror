#!/usr/bin/env zsh
# ============================================================================
# Main Installation Orchestrator
# ============================================================================
# This script coordinates all installation steps in the correct order
# to ensure system consistency and prevent breaking dependencies
#
# Usage: ./install.zsh [options]
#   --help, -h              Show this help message
#   --skip-dnf              Skip DNF package installations
#   --skip-flatpak          Skip Flatpak installations
#   --skip-others           Skip custom tool installations
#   --skip-zsh              Skip Zsh installation and configuration
# ============================================================================

set -euo pipefail

# Get script directory
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    readonly SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Import all helper functions
source "${SCRIPT_DIR}/helpers/check-install.zsh"
source "${SCRIPT_DIR}/dnf.zsh"
source "${SCRIPT_DIR}/flatpack.zsh"
source "${SCRIPT_DIR}/others.zsh"
source "${SCRIPT_DIR}/zsh.zsh"
source "${REPO_ROOT}/fonts/powerlevel.zsh"

# ============================================================================
# Global Configuration
# ============================================================================

declare -g SKIP_DNF=false
declare -g SKIP_FLATPAK=false
declare -g SKIP_OTHERS=false
declare -g SKIP_ZSH=false
declare -g FAILED_STEPS=()
declare -g SUCCESSFUL_STEPS=()

# ============================================================================
# Helper Functions
# ============================================================================

show_help() {
    cat << 'EOF'
Linux Mirror Installation Script
=================================

This script automates the installation and configuration of development
tools, utilities, and applications for your Linux system.

USAGE:
  ./install.zsh [options]

OPTIONS:
  --help, -h              Show this help message
  --skip-dnf              Skip DNF package installations
  --skip-flatpak          Skip Flatpak installations
  --skip-others           Skip custom tool installations (spf, vscode)
  --skip-zsh              Skip Zsh shell installation and configuration

EXAMPLES:
  # Run full installation
  ./install.zsh

  # Skip Flatpak installations
  ./install.zsh --skip-flatpak

  # Skip multiple components
  ./install.zsh --skip-dnf --skip-others

INSTALLATION ORDER:
  1. Zsh Shell (required for other scripts)
  2. DNF Packages (AI, CLI tools, Design, Dev tools, File management)
  3. Flatpak Applications
  4. Custom Tools (Superfile, Visual Studio Code)
  5. Powerlevel Fonts
  6. Application Configuration

NOTES:
  - This script requires sudo access for package installations
  - Some installations may require system reboot
  - Internet connection is required
  - Review available disk space before installation

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --skip-dnf)
                SKIP_DNF=true
                log_info "DNF installations will be skipped"
                shift
                ;;
            --skip-flatpak)
                SKIP_FLATPAK=true
                log_info "Flatpak installations will be skipped"
                shift
                ;;
            --skip-others)
                SKIP_OTHERS=true
                log_info "Custom tool installations will be skipped"
                shift
                ;;
            --skip-zsh)
                SKIP_ZSH=true
                log_info "Zsh installation will be skipped"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

record_step_success() {
    local step="$1"
    SUCCESSFUL_STEPS+=("$step")
    log_success "✓ $step completed"
}

record_step_failure() {
    local step="$1"
    FAILED_STEPS+=("$step")
    log_error "✗ $step failed"
}

# ============================================================================
# Pre-Installation Checks
# ============================================================================

run_pre_checks() {
    print_section "Running Pre-Installation Checks"
    
    # Check if running on supported system
    if [[ ! -f /etc/os-release ]]; then
        log_error "Unable to detect Linux distribution"
        return 1
    fi
    
    source /etc/os-release
    log_info "Detected: $PRETTY_NAME"
    
    if [[ "$ID" != "fedora" ]]; then
        log_warning "This script is designed for Fedora. You are running $PRETTY_NAME."
        log_warning "Some commands may not work correctly on your system."
        read -q "response?Do you want to continue anyway? (y/n) " || {
            log_error "Installation cancelled by user"
            return 1
        }
        echo
    fi
    
    # Check for internet connectivity
    log_info "Checking internet connectivity..."
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_warning "No internet connection detected. Some installations may fail."
        read -q "response?Continue anyway? (y/n) " || {
            log_error "Installation cancelled by user"
            return 1
        }
        echo
    fi
    
    # Check disk space
    log_info "Checking available disk space..."
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 5242880 ]]; then  # 5GB in KB
        log_warning "Low disk space available: $(numfmt --to=iec $((available_space * 1024)) 2>/dev/null || echo "$available_space KB")"
        read -q "response?Continue anyway? (y/n) " || {
            log_error "Installation cancelled by user"
            return 1
        }
        echo
    fi
    
    # Check sudo access
    log_info "Checking sudo access..."
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo access for package installations"
        log_info "You may be prompted for your password"
    fi
    
    log_success "Pre-installation checks passed!"
    return 0
}

# ============================================================================
# Installation Steps
# ============================================================================

run_installation() {
    print_section "Starting System Installation and Configuration"
    
    local total_steps=6
    local current_step=0
    
    # Step 1: Zsh Installation
    if [[ "$SKIP_ZSH" == false ]]; then
        ((current_step++))
        log_info "[$current_step/$total_steps] Installing Zsh..."
        if install_zsh_all; then
            record_step_success "Zsh installation and configuration"
        else
            record_step_failure "Zsh installation and configuration"
        fi
    fi
    
    # Step 2: DNF Packages
    if [[ "$SKIP_DNF" == false ]]; then
        ((current_step++))
        log_info "[$current_step/$total_steps] Installing DNF packages..."
        if install_dnf_all; then
            record_step_success "DNF package installations"
        else
            record_step_failure "DNF package installations"
        fi
    fi
    
    # Step 3: Flatpak Applications
    if [[ "$SKIP_FLATPAK" == false ]]; then
        ((current_step++))
        log_info "[$current_step/$total_steps] Installing Flatpak applications..."
        if install_flatpak_all; then
            record_step_success "Flatpak installations"
        else
            record_step_failure "Flatpak installations"
            log_warning "This may not be critical - continuing with other installations"
        fi
    fi
    
    # Step 4: Custom Tools
    if [[ "$SKIP_OTHERS" == false ]]; then
        ((current_step++))
        log_info "[$current_step/$total_steps] Installing custom tools..."
        if install_others_all; then
            record_step_success "Custom tool installations"
        else
            record_step_failure "Custom tool installations"
        fi
    fi

    # Step 5: Powerlevel Fonts
    ((current_step++))
    log_info "[$current_step/$total_steps] Installing Powerlevel fonts..."
    if install_fonts_all; then
        record_step_success "Powerlevel font installation"
    else
        record_step_failure "Powerlevel font installation"
    fi

    # Step 6: Apply configuration files
    ((current_step++))
    log_info "[$current_step/$total_steps] Applying configuration files..."
    if apply_configs_all; then
        record_step_success "Configuration deployment"
    else
        record_step_failure "Configuration deployment"
    fi
}

# ============================================================================
# Font and Configuration Deployment
# ============================================================================

install_fonts_all() {
    print_section "Installing Powerlevel Fonts"

    if [[ ! -f "${REPO_ROOT}/fonts/powerlevel.zsh" ]]; then
        log_warning "Font installer script not found; skipping font installation"
        return 1
    fi

    if ! command -v curl &> /dev/null; then
        log_error "curl is required to install fonts"
        return 1
    fi

    if install_fonts; then
        log_success "Powerlevel fonts installed successfully"
        return 0
    fi

    return 1
}

apply_configs_all() {
    print_section "Applying Configuration Files"

    local config_root="${REPO_ROOT}/configs"
    local target

    if [[ -d "${config_root}/kitty" ]]; then
        target="$HOME/.config/kitty"
        mkdir -p "$target"
        cp -f "${config_root}/kitty/kitty.conf" "$target/kitty.conf"
        cp -f "${config_root}/kitty/current-theme.conf" "$target/current-theme.conf"
        log_info "Kitty configuration copied"
    fi

    if [[ -d "${config_root}/nvim" ]]; then
        target="$HOME/.config/nvim"
        mkdir -p "${target}/lua"
        cp -f "${config_root}/nvim/init.lua" "$target/init.lua"
        cp -f "${config_root}/nvim/lazy-lock.json" "$target/lazy-lock.json"
        cp -f "${config_root}/nvim/lua/plugins.lua" "$target/lua/plugins.lua"
        log_info "Neovim configuration copied"
    fi

    if [[ -f "${config_root}/p10k/.p10k.zsh" ]]; then
        cp -f "${config_root}/p10k/.p10k.zsh" "$HOME/.p10k.zsh"
        log_info "Powerlevel10k configuration copied"
    fi

    if [[ -f "${config_root}/zsh/.zshrc" ]]; then
        cp -f "${config_root}/zsh/.zshrc" "$HOME/.zshrc"
        log_info "Zsh configuration copied"
    fi

    if [[ -d "${config_root}/zsh/.zsh" ]]; then
        mkdir -p "$HOME/.zsh"
        cp -Rf "${config_root}/zsh/.zsh/." "$HOME/.zsh/"
        log_info "Zsh helper files copied"
    fi

    log_success "Configuration files deployed"
    return 0
}

show_summary() {
    print_section "Installation Summary"
    
    if [[ ${#SUCCESSFUL_STEPS[@]} -gt 0 ]]; then
        echo -e "${COLOR_GREEN}Completed Steps:${COLOR_NC}"
        for step in "${SUCCESSFUL_STEPS[@]}"; do
            echo -e "  ${COLOR_GREEN}✓${COLOR_NC} $step"
        done
    fi
    
    if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
        echo -e "\n${COLOR_RED}Failed Steps:${COLOR_NC}"
        for step in "${FAILED_STEPS[@]}"; do
            echo -e "  ${COLOR_RED}✗${COLOR_NC} $step"
        done
    fi
    
    if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
        log_success "All installations completed successfully!"
        echo -e "\n${COLOR_GREEN}Next steps:${COLOR_NC}"
        echo "  1. Review your shell configuration in ~/.zshrc"
        echo "  2. Install PowerLevel10k: https://github.com/romkatv/powerlevel10k"
        echo "  3. Configure your terminal theme"
        echo "  4. Consider running: chsh -s /bin/zsh"
        return 0
    else
        log_warning "Installation completed with some failures"
        echo -e "\nYou can manually fix the failed steps and re-run this script."
        return 1
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    clear
    
    # Parse command-line arguments
    parse_arguments "$@"
    
    # Show welcome banner
    echo -e "${COLOR_BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                     LINUX MIRROR INSTALLER                              ║
║                  System Setup & Configuration Tool                       ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLOR_NC}\n"
    
    # Run pre-installation checks
    if ! run_pre_checks; then
        log_error "Pre-installation checks failed"
        exit 1
    fi
    
    # Confirm before starting
    echo
    read -q "response?Do you want to continue with the installation? (y/n) " || {
        log_error "Installation cancelled by user"
        exit 0
    }
    echo -e "\n"
    
    # Run installation steps
    run_installation || true
    
    # Show summary
    show_summary
}

# ============================================================================
# Script Entry Point
# ============================================================================

if [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
