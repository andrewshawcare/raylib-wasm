#!/bin/bash

# Raylib Native Build Script
# This script builds the raylib project as a native executable using Conan

set -e  # Exit on any error

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Building Raylib project for native execution..."

# Check prerequisites
check_conan

# Install dependencies with Conan
echo "Installing dependencies with Conan..."
conan install . --profile:build=default --profile:host=default --build=missing

# Create and enter build directory
ensure_directory "build-native"
cd build-native

# Configure the project with Conan toolchain
echo "Configuring project..."
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../build/Release/generators/conan_toolchain.cmake

# Build the project
echo "Building project..."
make -j$(nproc)

# Check if build was successful
if check_build_success "raylib-wasm" "Native"; then
    echo ""
    echo "Executable: build-native/raylib-wasm"
    echo ""
    
    # Check if auto-run is enabled via environment variable
    if [ "$AUTO_RUN" = "1" ]; then
        echo "Starting application..."
        
        # Kill any existing raylib-wasm processes
        cleanup_processes "raylib-wasm"
        sleep 0.1  # Brief pause to ensure process cleanup
        
        ./raylib-wasm &
        APP_PID=$!
        echo "Native application started (PID: $APP_PID)"
    else
        # Ask if user wants to run the executable (interactive mode)
        echo "To run your application:"
        echo "  ./build-native/raylib-wasm"
        echo ""
        read -p "Would you like to run the application now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Running application..."
            ./raylib-wasm
        fi
    fi
fi