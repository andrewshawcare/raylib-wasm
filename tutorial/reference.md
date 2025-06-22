# 📋 Quick Reference: Commands & Cheat Sheets

Your go-to reference for commands, configurations, and quick solutions. Bookmark this page!

## 🚀 Essential Commands

### Build Commands
```bash
# Build native desktop version
./build-native.sh

# Build WebAssembly version  
./build-wasm.sh

# Watch files and auto-rebuild
./watch.sh

# Clean all build artifacts
./cleanup.sh
```

### Development Workflow
```bash
# Start development session
./watch.sh

# Test native build
cd build-native && ./raylib-wasm

# Test WebAssembly build
cd build-wasm && python3 -m http.server 8080
# Open: http://localhost:8080/raylib-wasm.html

# Emergency rebuild
./cleanup.sh && ./build-native.sh && ./build-wasm.sh
```

## 🔧 CMake Quick Reference

### Common CMake Commands
```bash
# Configure project
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build project
cmake --build . --parallel $(nproc)

# Install project
cmake --install .

# Clean build
cmake --build . --target clean
```

### Build Types
```bash
# Debug build (slow, debuggable)
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Release build (fast, optimized)
cmake .. -DCMAKE_BUILD_TYPE=Release

# RelWithDebInfo (optimized + debug symbols)
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

# MinSizeRel (smallest binary size)
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel
```

### Platform Detection
```cmake
# Platform checks in CMakeLists.txt
if(WIN32)           # Windows
if(APPLE)           # macOS
if(UNIX)            # Linux/Unix
if(EMSCRIPTEN)      # WebAssembly
```

## 📦 Conan Quick Reference

### Basic Commands
```bash
# Install dependencies
conan install .

# Install with missing builds
conan install . --build=missing

# Update dependencies
conan install . --update

# Clean cache
conan remove "*" --confirm
```

### Profile Management
```bash
# Show current profile
conan profile show default

# Detect profile automatically
conan profile detect --force

# List profiles
conan profile list

# Create new profile
conan profile new myprofile
```

### Package Information
```bash
# Search packages
conan search raylib

# Show package info
conan inspect raylib/5.5@

# List installed packages
conan list
```

## 🌐 Emscripten Quick Reference

### Environment Setup
```bash
# Install emsdk
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

### Compilation Commands
```bash
# Basic compilation
emcc main.c -o output.html

# With CMake
emcmake cmake ..
emmake make

# With optimization
emcc main.c -O3 -o output.html
```

### Common Flags
```bash
-s WASM=1                    # Generate WebAssembly
-s USE_GLFW=3               # Use GLFW for windowing
-s ASSERTIONS=1             # Enable runtime assertions
-s ASYNCIFY                 # Enable async operations
-O3                         # Maximum optimization
--preload-file assets/      # Include files in build
```

## 🐛 Debugging Reference

### GDB Commands
```bash
# Start debugging
gdb ./raylib-wasm

# Common GDB commands
(gdb) run                   # Start program
(gdb) break main            # Set breakpoint
(gdb) continue              # Continue execution
(gdb) next                  # Step over
(gdb) step                  # Step into
(gdb) print variable        # Print variable value
(gdb) backtrace            # Show call stack
(gdb) quit                 # Exit debugger
```

### Valgrind Commands
```bash
# Memory leak detection
valgrind --leak-check=full ./raylib-wasm

# Memory error detection
valgrind --tool=memcheck ./raylib-wasm

# Profiling
valgrind --tool=callgrind ./raylib-wasm
```

### Performance Profiling
```bash
# Linux perf
perf record ./raylib-wasm
perf report

# Time execution
time ./raylib-wasm

# Memory usage
/usr/bin/time -v ./raylib-wasm
```

## 🔍 File System Reference

### Project Structure
```
raylib-wasm/
├── main.c                 # Source code
├── CMakeLists.txt         # Build configuration
├── conanfile.txt          # Dependencies
├── build-common.sh        # Shared utilities
├── build-native.sh        # Native build script
├── build-wasm.sh          # WebAssembly build script
├── watch.sh               # File watcher
├── cleanup.sh             # Clean build artifacts
├── tutorial/              # Tutorial files
├── build-native/          # Native build output
├── build-wasm/            # WebAssembly build output
└── build/                 # Conan artifacts
```

### Generated Files
```
build-native/
├── raylib-wasm            # Native executable
├── CMakeCache.txt         # CMake configuration cache
└── Makefile               # Build instructions

build-wasm/
├── raylib-wasm.html       # WebAssembly wrapper page
├── raylib-wasm.js         # JavaScript runtime
├── raylib-wasm.wasm       # WebAssembly binary
└── raylib-wasm.data       # Assets (if any)

build/Release/generators/
├── conan_toolchain.cmake  # CMake toolchain
├── raylib-config.cmake    # Raylib CMake config
└── conanbuild.sh          # Environment variables
```

## 🎮 Code Modification Reference

### Configuration Constants
```c
// In main.c - easy to modify
#define SCREEN_WIDTH 800        // Window width
#define SCREEN_HEIGHT 450       // Window height
#define TARGET_FPS 60           // Frame rate limit
#define NUM_BALLS 2500          // Number of balls
#define BALL_RADIUS 20.0f       // Ball size
#define BALL_MIN_SPEED 2.0f     // Minimum speed
#define BALL_MAX_SPEED 8.0f     // Maximum speed
```

### Quick Experiments
```c
// Double the chaos
#define NUM_BALLS 5000

// Bigger balls
#define BALL_RADIUS 30.0f

// Faster movement
#define BALL_MAX_SPEED 15.0f

// Different colors (add to ballColors array)
Color ballColors[] = {RED, BLUE, GREEN, YELLOW, PURPLE, 
                      ORANGE, PINK, GOLD, LIME, MAROON};
```

### Physics Modifications
```c
// Add gravity (in UpdateBall function)
ball->velocity.y += 0.2f;  // Gravity acceleration

// Add friction
ball->velocity.x *= 0.999f;  // Slow down over time
ball->velocity.y *= 0.999f;

// Bouncy walls (modify collision response)
ball->velocity.x *= -0.8f;  // Less bouncy
```

## 🌐 Platform-Specific Reference

### Linux Commands
```bash
# Install dependencies (Ubuntu/Debian)
sudo apt update
sudo apt install build-essential cmake python3-pip git
pip3 install conan

# Install graphics libraries
sudo apt install libgl1-mesa-dev libx11-dev

# Check system info
uname -a
lscpu
glxinfo | grep "OpenGL"
```

### macOS Commands
```bash
# Install Xcode tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install cmake conan

# Check system info
system_profiler SPHardwareDataType
```

### Windows (WSL) Commands
```bash
# Install WSL
wsl --install

# Update packages
sudo apt update && sudo apt upgrade

# Install build tools
sudo apt install build-essential cmake python3-pip
```

## 🔧 Environment Variables

### Build Configuration
```bash
# Auto-run native build
export AUTO_RUN=1
./build-native.sh

# Auto-serve WebAssembly build
export AUTO_SERVE=1
export SERVE_PORT=8080
./build-wasm.sh

# CMake configuration
export CMAKE_BUILD_TYPE=Release
export CMAKE_GENERATOR="Unix Makefiles"

# Conan configuration
export CONAN_USER_HOME="$HOME/.conan-cache"
```

### Emscripten Configuration
```bash
# Emscripten environment
export EMSDK=/path/to/emsdk
export EM_CONFIG=$EMSDK/.emscripten
export EMSDK_NODE=$EMSDK/node/16.20.0_64bit/bin/node

# WebAssembly memory
export EMCC_WASM_BACKEND=1
export EMCC_DEBUG=1  # For debugging builds
```

## 📊 Performance Reference

### Optimization Levels
```
Optimization Comparison:
┌─────────┬─────────────┬─────────────┬─────────────┐
│ Level   │ Build Time  │ Runtime     │ Binary Size │
├─────────┼─────────────┼─────────────┼─────────────┤
│ -O0     │ Fast        │ Slow        │ Large       │
│ -O1     │ Medium      │ Medium      │ Medium      │
│ -O2     │ Slower      │ Fast        │ Small       │
│ -O3     │ Slowest     │ Fastest     │ Smallest    │
└─────────┴─────────────┴─────────────┴─────────────┘
```

### Memory Usage
```
Typical Memory Usage:
┌─────────────┬─────────────┬─────────────┐
│ Platform    │ RAM Usage   │ VRAM Usage  │
├─────────────┼─────────────┼─────────────┤
│ Native C    │ 8-15 MB     │ 10-20 MB    │
│ WebAssembly │ 25-40 MB    │ 15-30 MB    │
│ JavaScript  │ 80-150 MB   │ 20-40 MB    │
└─────────────┴─────────────┴─────────────┘
```

### Performance Targets
```c
// Performance goals for 2500 balls:
// Native:      60 FPS stable, <10% CPU usage
// WebAssembly: 55-60 FPS, <25% CPU usage
// Memory:      <50 MB total usage
```

## 🚨 Emergency Procedures

### Quick Fix Commands
```bash
# Permission fix
chmod +x *.sh

# Clean rebuild
./cleanup.sh && ./build-native.sh

# Reset Conan
conan remove "*" --confirm
conan profile detect --force

# Reset everything
rm -rf build* emsdk/ ~/.conan2/p/raylib*
./build-native.sh
```

### Verification Commands
```bash
# Check prerequisites
gcc --version && cmake --version && conan --version

# Check build outputs
ls -la build-native/raylib-wasm build-wasm/raylib-wasm.html

# Test executables
file build-native/raylib-wasm
ldd build-native/raylib-wasm
```

### System Information
```bash
# Comprehensive system check
echo "=== System Information ==="
uname -a
echo "=== CPU Information ==="
lscpu | grep -E "(Model|MHz|Core|Thread)"
echo "=== Memory Information ==="
free -h
echo "=== Graphics Information ==="
glxinfo | grep -E "(OpenGL|renderer)" || echo "No GL info"
echo "=== Tool Versions ==="
gcc --version | head -1
cmake --version | head -1
python3 --version
conan --version 2>/dev/null || echo "Conan not installed"
```

## 🎯 Common File Locations

### Configuration Files
```bash
# CMake cache
build-native/CMakeCache.txt

# Conan profile
~/.conan2/profiles/default

# Conan cache
~/.conan2/p/

# Emscripten config
emsdk/.emscripten
```

### Log Files
```bash
# Build logs
build-native/CMakeOutput.log
build-native/CMakeError.log

# Conan logs
~/.conan2/logs/

# System logs
/var/log/messages  # Linux
~/Library/Logs/    # macOS
```

## 📱 Mobile Quick Commands

### One-Liners
```bash
# Quick build test
./build-native.sh && echo "✅ Native OK" || echo "❌ Native failed"

# Quick web test  
./build-wasm.sh && echo "✅ WASM OK" || echo "❌ WASM failed"

# Performance test
time ./build-native/raylib-wasm &

# Memory test
valgrind --tool=massif ./build-native/raylib-wasm

# Web server
cd build-wasm && python3 -m http.server 8080 &
```

### Aliases (add to ~/.bashrc)
```bash
alias rn='./build-native.sh'
alias rw='./build-wasm.sh'
alias rwatch='./watch.sh'
alias rclean='./cleanup.sh'
alias rtest='./build-native.sh && ./build-wasm.sh'
```

---

**Need help with errors?** → [Troubleshooting Guide](troubleshooting.md)

**Want the full tutorial?** → [Tutorial Hub](README.md)

*Last updated: 2024 | Quick reference for rapid development*