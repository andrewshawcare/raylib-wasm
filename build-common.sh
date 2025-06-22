#!/bin/bash

# Raylib Build Common Functions
# Shared utility functions for build scripts

# Color codes for output (if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Print error message and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Print warning message
warning() {
    echo -e "${YELLOW}Warning: $1${NC}" >&2
}

# Print success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        error_exit "$1 not found. Please install $1 first."
    fi
}

# Check if Conan is installed and configured
check_conan() {
    check_command "conan"
    
    # Detect default profile if it doesn't exist
    if [ ! -f "$HOME/.conan2/profiles/default" ]; then
        echo "Creating default Conan profile..."
        conan profile detect --force
    fi
}

# Clean up processes by name pattern
cleanup_processes() {
    local pattern="$1"
    if [ -n "$pattern" ]; then
        pkill -f "$pattern" 2>/dev/null || true
    fi
}

# Kill web server if PID file exists
cleanup_webserver() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if [ -n "$pid" ]; then
            kill "$pid" 2>/dev/null || true
            rm -f "$pid_file"
        fi
    fi
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Check if build was successful by looking for expected output file
check_build_success() {
    local expected_file="$1"
    local build_type="$2"
    
    if [ -f "$expected_file" ]; then
        success "Build successful!"
        return 0
    else
        error_exit "$build_type build failed!"
        return 1
    fi
}