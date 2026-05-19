#!/usr/bin/env zsh
# ============================================================================
# Helper Functions for Installation Management
# ============================================================================

if [[ -n "${COLOR_RED:-}" ]]; then
    return 0
fi

# Colors for output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m' # No Color

# ============================================================================
# Utility Functions
# ============================================================================

## Check if a command is installed
check_install() {
    local command="$1"
    local name="${2:-$1}"

    if command -v "$command" &> /dev/null; then
        log_info "✓ $name is already installed."
        return 0
    fi
    return 1
}

## Log functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[✓ SUCCESS]${COLOR_NC} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $*" >&2
}

## Print section header
print_section() {
    local section="$1"
    echo -e "\n${COLOR_BLUE}════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_BLUE}  $section${COLOR_NC}"
    echo -e "${COLOR_BLUE}════════════════════════════════════════${COLOR_NC}\n"
}

## Execute command with error handling
execute_cmd() {
    local cmd="$1"
    local error_msg="${2:-Command failed}"
    
    if eval "$cmd"; then
        return 0
    else
        log_error "$error_msg"
        return 1
    fi
}

## Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        return 1
    fi
    return 0
}