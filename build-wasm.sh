#!/bin/bash

# Raylib WebAssembly Build Script
# This script builds the raylib project for WebAssembly using Conan for emsdk only

set -e  # Exit on any error

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Building Raylib project for WebAssembly..."

# Check prerequisites
check_conan

# Install emsdk via Conan for build tools
echo "Installing Emscripten SDK with Conan..."
conan install conanfile.txt --profile:build=default --profile:host=default --build=missing

# Activate Emscripten environment
echo "Activating Emscripten environment..."
source build/Release/generators/conanbuild.sh

# Verify Emscripten tools are available
if ! command -v emcc &> /dev/null; then
    warning "Emscripten tools not found after activation. Trying alternative approach..."
    
    # Fallback: Use emsdk directly
    if [ ! -d "emsdk" ]; then
        echo "Downloading Emscripten SDK..."
        check_command "git"
        git clone https://github.com/emscripten-core/emsdk.git
        cd emsdk
        ./emsdk install latest
        ./emsdk activate latest
        cd ..
    fi
    
    source emsdk/emsdk_env.sh
fi

echo "Emscripten tools found: $(which emcc)"

# Create and enter build directory
ensure_directory "build-wasm"
cd build-wasm

# Configure the project with Emscripten toolchain (using FetchContent for raylib)
echo "Configuring project..."
emcmake cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_CONAN_RAYLIB=OFF

# Build the project
echo "Building project..."
emmake make -j$(nproc)

# Check if build was successful
if check_build_success "raylib-wasm.html" "WebAssembly"; then
    echo ""
    echo "Files generated:"
    echo "  - raylib-wasm.html"
    echo "  - raylib-wasm.js" 
    echo "  - raylib-wasm.wasm"
    echo ""
    
    # Check if auto-serve is enabled via environment variable
    if [ "$AUTO_SERVE" = "1" ]; then
        SERVE_PORT=${SERVE_PORT:-8080}
        echo "Starting web server on port $SERVE_PORT..."
        check_command "python3"
        python3 -m http.server $SERVE_PORT &
        SERVER_PID=$!
        echo "Web server started (PID: $SERVER_PID)"
        echo "Open: http://localhost:$SERVE_PORT/raylib-wasm.html"
        
        # Store server PID for potential cleanup
        echo $SERVER_PID > .webserver.pid
    else
        echo "To test your application:"
        echo "  1. cd build-wasm"
        echo "  2. python3 -m http.server 8080"
        echo "  3. Open http://localhost:8080/raylib-wasm.html"
    fi
    echo ""
fi