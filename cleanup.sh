#!/bin/bash

# Raylib Project Cleanup Script
# This script removes all build artifacts and downloaded dependencies

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Cleaning up Raylib project..."

# Track what we're removing for user feedback
removed_items=()

# Remove build directories
if [ -d "build-wasm" ]; then
    echo "  Removing build-wasm/ directory..."
    rm -rf build-wasm
    removed_items+=("WebAssembly build artifacts")
fi

if [ -d "build-native" ]; then
    echo "  Removing build-native/ directory..."
    rm -rf build-native
    removed_items+=("Native build artifacts")
fi

# Remove Conan build directory
if [ -d "build" ]; then
    echo "  Removing build/ directory (Conan artifacts)..."
    rm -rf build
    removed_items+=("Conan build artifacts")
fi

# Remove any stray CMake files in root
if [ -d "CMakeFiles" ]; then
    echo "  Removing CMakeFiles/ directory..."
    rm -rf CMakeFiles
    removed_items+=("CMake cache files")
fi

# Remove individual CMake files
cmake_files=("CMakeCache.txt" "Makefile" "cmake_install.cmake" "CPackConfig.cmake" "CPackSourceConfig.cmake")
for file in "${cmake_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  Removing $file..."
        rm -f "$file"
        removed_items+=("CMake files")
    fi
done

# Remove _deps directory if it exists
if [ -d "_deps" ]; then
    echo "  Removing _deps/ directory..."
    rm -rf _deps
    removed_items+=("Downloaded dependencies")
fi

# Clean up web server PID files and processes
cleanup_webserver "build-wasm/.webserver.pid"
if [ -f "build-wasm/.webserver.pid" ]; then
    removed_items+=("Web server PID files")
fi

# Kill any running processes
cleanup_processes "raylib-wasm"
cleanup_processes "python3 -m http.server"

# Provide feedback
if [ ${#removed_items[@]} -eq 0 ]; then
    echo "Project is already clean!"
else
    echo ""
    echo "Cleanup complete! Removed:"
    printf "  - %s\n" "${removed_items[@]}"
    echo ""
    echo "Remaining files:"
    echo "  - main.c (source code)"
    echo "  - CMakeLists.txt (build config)"
    echo "  - *.sh scripts"
    echo "  - README.md, .gitignore"
fi

echo ""
echo "Ready for a fresh build!"