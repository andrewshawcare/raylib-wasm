#!/bin/bash

# Raylib Project File Watcher Script
# This script watches main.c for changes and automatically rebuilds both versions

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Raylib File Watcher Starting..."
echo ""

# Check if inotify-tools is installed
if ! command -v inotifywait &> /dev/null; then
    echo "Installing inotify-tools for file watching..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y inotify-tools
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y inotify-tools
    elif command -v pacman &> /dev/null; then
        sudo pacman -S inotify-tools
    else
        error_exit "Could not install inotify-tools automatically. Please install inotify-tools manually for your system."
    fi
fi

# Cleanup function that runs on script exit
cleanup_on_exit() {
    echo ""
    echo "File watcher stopped. Cleaning up background processes..."
    
    # Kill any running native applications
    cleanup_processes "raylib-wasm"
    
    # Kill any web servers we started
    cleanup_webserver "build-wasm/.webserver.pid"
    
    # Kill any python http servers
    cleanup_processes "python3 -m http.server"
    
    echo "Running project cleanup..."
    ./cleanup.sh
    echo "Goodbye!"
    exit 0
}

# Set up trap to run cleanup when script is interrupted (Ctrl+C or kill signals)
trap cleanup_on_exit SIGINT SIGTERM

echo "Watching main.c for changes..."
echo "When main.c is modified, both WebAssembly and native builds will run automatically"
echo "Press Ctrl+C to stop watching and cleanup"
echo ""
echo "====================================="
echo ""

# Initial build with auto-run/serve enabled
echo "Running initial builds..."
echo ""

echo "Building WebAssembly version..."
if AUTO_SERVE=1 SERVE_PORT=8080 ./build-wasm.sh; then
    success "WebAssembly build successful!"
else
    warning "WebAssembly build failed, but continuing to watch..."
fi
echo ""

echo "Building native version..."
if AUTO_RUN=1 ./build-native.sh; then
    success "Native build successful!"
else
    warning "Native build failed, but continuing to watch..."
fi
echo ""

echo "Initial builds complete!"
echo ""
echo "Now watching for changes to main.c..."
echo ""

# Watch for changes to main.c (monitor mode keeps running)
inotifywait -m -e modify main.c |
while read path action file; do
    echo ""
    echo "Change detected in main.c!"
    echo "Rebuilding both versions..."
    echo ""
    
    # Build WebAssembly version with auto-serve
    echo "Building WebAssembly version..."
    if AUTO_SERVE=1 SERVE_PORT=8080 ./build-wasm.sh; then
        success "WebAssembly build successful!"
    else
        warning "WebAssembly build failed!"
    fi
    echo ""
    
    # Build native version with auto-run
    echo "Building native version..."
    if AUTO_RUN=1 ./build-native.sh; then
        success "Native build successful!"
    else
        warning "Native build failed!"
    fi
    echo ""
    
    echo "Rebuild complete! Watching for next change..."
    echo ""
done