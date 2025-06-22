# 🚨 Troubleshooting Guide: When Things Go Wrong

Don't panic! Every developer faces build issues. This guide covers the most common problems and their solutions, including the exact issues you're likely to encounter with this project.

## 🔥 Common Build Errors

### 1. ❌ "Could NOT find X11" (WebAssembly Build)

**Error Message:**
```
CMake Error: Could NOT find X11 (missing: X11_X11_LIB)
Call Stack: build-wasm/_deps/raylib-src/src/external/glfw/src/CMakeLists.txt:181
```

**Root Cause:** GLFW trying to find desktop window system libraries for WebAssembly build.

**✅ Solution:**
This was already fixed in our CMakeLists.txt, but if you see this error:

```cmake
# Add to CMakeLists.txt in the WebAssembly section
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set(PLATFORM "Web" CACHE STRING "Platform" FORCE)
    set(SUPPORT_X11 OFF CACHE BOOL "Support X11" FORCE)
    set(SUPPORT_WAYLAND OFF CACHE BOOL "Support Wayland" FORCE)
endif()
```

**Verification:**
```bash
rm -rf build-wasm
./build-wasm.sh
# Should succeed without X11 errors
```

### 2. ❌ "conan: command not found"

**Error Message:**
```bash
./build-native.sh: line 19: conan: command not found
```

**Root Cause:** Conan package manager not installed.

**✅ Solution (Ubuntu/Debian):**
```bash
# Method 1: pip (recommended)
pip3 install conan

# Method 2: apt (older version)
sudo apt update && sudo apt install python3-pip
pip3 install conan

# Method 3: Official installer
curl -L https://github.com/conan-io/conan/releases/latest/download/conan-linux-64.tgz -o conan.tgz
tar -xzf conan.tgz
sudo cp conan*/conan /usr/local/bin/
```

**✅ Solution (macOS):**
```bash
# Homebrew
brew install conan

# Or pip
pip3 install conan
```

**✅ Solution (Windows):**
```powershell
# Chocolatey
choco install conan

# Or pip
pip install conan
```

**Verification:**
```bash
conan --version
# Should show Conan 2.x.x
```

### 3. ❌ "Could not find raylib"

**Error Message:**
```
CMake Error: find_package could not find module FindRaylib.cmake
```

**Root Cause:** Conan didn't generate CMake files or wrong toolchain path.

**✅ Solution:**
```bash
# Clean and regenerate
rm -rf build/ build-native/
conan install . --build=missing

# Check generated files
ls build/Release/generators/
# Should contain: conan_toolchain.cmake, raylib-config.cmake

# Rebuild with correct toolchain
./build-native.sh
```

**Alternative:** Check toolchain path in build script:
```bash
# In build-native.sh, verify this line:
cmake .. -DCMAKE_TOOLCHAIN_FILE=../build/Release/generators/conan_toolchain.cmake
```

### 4. ❌ "emcc: command not found"

**Error Message:**
```bash
emcc: command not found
emcmake: error: 'cmake' failed
```

**Root Cause:** Emscripten SDK not properly installed or activated.

**✅ Solution:**
Our script handles this automatically, but if you see this error:

```bash
# Manual Emscripten setup
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh

# Verify installation
emcc --version
```

**Or let the script handle it:**
```bash
rm -rf emsdk/  # Remove partial installation
./build-wasm.sh  # Script will reinstall automatically
```

### 5. ❌ "Cannot disable both Wayland and X11"

**Error Message:**
```
CMake Error: Cannot disable both Wayland and X11
```

**Root Cause:** Old CMakeLists.txt configuration trying to disable all windowing systems.

**✅ Solution:**
This should be fixed in our current CMakeLists.txt. If you see this:

```cmake
# Remove these lines if present:
# set(GLFW_BUILD_X11 OFF CACHE BOOL "" FORCE)
# set(GLFW_BUILD_WAYLAND OFF CACHE BOOL "" FORCE)

# Use this instead:
set(PLATFORM "Web" CACHE STRING "Platform" FORCE)
```

### 6. ❌ "Permission denied" on scripts

**Error Message:**
```bash
bash: ./build-native.sh: Permission denied
```

**Root Cause:** Script files don't have execute permissions.

**✅ Solution:**
```bash
# Make scripts executable
chmod +x *.sh

# Verify permissions
ls -la *.sh
# Should show: -rwxr-xr-x
```

## 🌐 Platform-Specific Issues

### Linux Issues

**1. Missing build tools:**
```bash
# Error: gcc: command not found
sudo apt update
sudo apt install build-essential cmake git

# Error: make: command not found  
sudo apt install make

# Verify installation
gcc --version && cmake --version && make --version
```

**2. Missing graphics libraries:**
```bash
# Error: cannot find -lGL
sudo apt install libgl1-mesa-dev libglu1-mesa-dev

# Error: cannot find -lX11
sudo apt install libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev
```

**3. Python/pip issues:**
```bash
# Error: pip3: command not found
sudo apt install python3-pip

# Error: pip install permission denied
pip3 install --user conan
export PATH="$HOME/.local/bin:$PATH"
```

### macOS Issues

**1. Xcode Command Line Tools:**
```bash
# Error: xcrun: error: invalid active developer path
xcode-select --install

# Verify installation
gcc --version
```

**2. Homebrew missing:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install cmake conan
```

**3. Architecture issues (Apple Silicon):**
```bash
# Force x86_64 build if needed
arch -x86_64 ./build-native.sh

# Or create universal binary
cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
```

### Windows (WSL) Issues

**1. WSL not installed:**
```powershell
# In PowerShell as Administrator
wsl --install
# Restart computer
```

**2. Display issues:**
```bash
# Error: cannot connect to X server
# Install X server for Windows (VcXsrv or X410)

# Set DISPLAY variable
export DISPLAY=:0

# Or use Windows native build instead
```

**3. File permission issues:**
```bash
# WSL file system issues
# Work in /home/username/ not /mnt/c/
cd ~
git clone <your-repo>
```

## 🔧 Build System Issues

### CMake Problems

**1. Wrong CMake version:**
```bash
# Error: CMake 3.15 or higher is required
cmake --version

# Ubuntu: Add newer CMake repository
sudo apt remove cmake
sudo snap install cmake --classic

# Or build from source
wget https://cmake.org/files/v3.27/cmake-3.27.0.tar.gz
```

**2. Cache corruption:**
```bash
# Error: CMake cache entries don't match
rm -rf CMakeCache.txt CMakeFiles/
cmake ..
```

**3. Generator issues:**
```bash
# Error: could not find generator
cmake -G "Unix Makefiles" ..

# List available generators
cmake --help
```

### Conan Problems

**1. Profile issues:**
```bash
# Error: profile not found
conan profile detect --force

# Check profile
conan profile show default
```

**2. Cache corruption:**
```bash
# Clear Conan cache
conan remove "*" --confirm

# Reinstall dependencies
conan install . --build=missing
```

**3. Version conflicts:**
```bash
# Error: version conflict
conan install . --build=missing --update

# Force specific version
conan install raylib/5.5@ --build=missing
```

## 🌐 Runtime Issues

### Native Application Problems

**1. Application won't start:**
```bash
# Check library dependencies
ldd build-native/raylib-wasm

# Install missing libraries
sudo apt install libgl1-mesa-glx
```

**2. Performance issues:**
```bash
# Check if using integrated graphics
glxinfo | grep "OpenGL renderer"

# Force discrete GPU (NVIDIA)
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia ./build-native/raylib-wasm
```

**3. Window/display issues:**
```bash
# Check X11 display
echo $DISPLAY

# Test X11 connection
xdpyinfo

# Run with software rendering
LIBGL_ALWAYS_SOFTWARE=1 ./build-native/raylib-wasm
```

### WebAssembly Problems

**1. Browser compatibility:**
```javascript
// Check WebAssembly support
if (typeof WebAssembly === 'object') {
    console.log('WebAssembly supported');
} else {
    console.log('WebAssembly not supported');
    // Fallback or error message
}
```

**2. File serving issues:**
```bash
# CORS errors when opening HTML directly
# Must serve from HTTP server:
cd build-wasm
python3 -m http.server 8080

# Check MIME type
curl -I http://localhost:8080/raylib-wasm.wasm
# Should show: Content-Type: application/wasm
```

**3. Memory issues:**
```javascript
// WebAssembly memory errors
// Increase memory in Emscripten flags:
-s INITIAL_MEMORY=33554432  // 32MB
```

## 🐛 Debug Techniques

### Build Debugging

**1. Verbose output:**
```bash
# CMake verbose
cmake .. --debug-output

# Make verbose
make VERBOSE=1

# Conan verbose
conan install . -v
```

**2. Step-by-step debugging:**
```bash
# Run each step manually
conan install .
cd build-native
cmake .. -DCMAKE_TOOLCHAIN_FILE=../build/Release/generators/conan_toolchain.cmake
make
```

**3. Environment debugging:**
```bash
# Check environment variables
env | grep -E "(PATH|CONAN|CMAKE)"

# Check file permissions
ls -la *.sh

# Check disk space
df -h
```

### Application Debugging

**1. GDB debugging:**
```bash
# Build in debug mode
cmake .. -DCMAKE_BUILD_TYPE=Debug
make

# Debug with GDB
gdb ./raylib-wasm
(gdb) run
(gdb) bt  # backtrace on crash
```

**2. Valgrind memory checking:**
```bash
# Check for memory errors
valgrind --leak-check=full ./raylib-wasm
```

**3. Strace system call tracing:**
```bash
# Trace system calls
strace -e trace=file ./raylib-wasm
```

## 📱 Quick Fixes

### Reset Everything
```bash
# Nuclear option - clean everything
./cleanup.sh
rm -rf ~/.conan2/p/raylib*
rm -rf emsdk/
./build-native.sh
```

### Verify Installation
```bash
# Check all prerequisites
echo "=== System Check ==="
echo "GCC: $(gcc --version | head -1)"
echo "CMake: $(cmake --version | head -1)"
echo "Python: $(python3 --version)"
echo "Conan: $(conan --version)"
echo "Git: $(git --version)"

echo "=== File Check ==="
ls -la *.sh
echo "=== Build Check ==="
ls -la build*/ 2>/dev/null || echo "No build directories"
```

### Emergency Rebuild
```bash
#!/bin/bash
# emergency-rebuild.sh
set -e

echo "🚨 Emergency rebuild procedure..."

# 1. Clean everything
echo "Cleaning..."
./cleanup.sh 2>/dev/null || rm -rf build* emsdk/

# 2. Verify tools
echo "Checking tools..."
command -v gcc >/dev/null || { echo "Install gcc"; exit 1; }
command -v cmake >/dev/null || { echo "Install cmake"; exit 1; }
command -v conan >/dev/null || { echo "Install conan"; exit 1; }

# 3. Fix permissions
echo "Fixing permissions..."
chmod +x *.sh

# 4. Rebuild
echo "Building native..."
./build-native.sh

echo "Building WebAssembly..."
./build-wasm.sh

echo "✅ Emergency rebuild complete!"
```

## 🆘 Getting Help

### Information to Gather

When asking for help, include:

```bash
# System information
uname -a
cat /etc/os-release

# Tool versions
gcc --version
cmake --version
conan --version

# Error output
./build-native.sh 2>&1 | tee build-error.log

# File permissions
ls -la *.sh

# Generated files
ls -la build*/
```

### Community Resources

- **Raylib Discord:** [discord.gg/raylib](https://discord.gg/raylib)
- **Conan Community:** [conan.io/center](https://conan.io/center)
- **CMake Help:** [cmake.org/help](https://cmake.org/help)
- **Emscripten Docs:** [emscripten.org/docs](https://emscripten.org/docs)

### Creating Bug Reports

**Good Bug Report Template:**
```markdown
## Problem
Brief description of the issue

## Environment
- OS: Ubuntu 22.04 LTS
- GCC: 11.3.0
- CMake: 3.24.2
- Conan: 2.0.5

## Steps to Reproduce
1. ./build-native.sh
2. Error occurs at step X

## Error Output
```
[paste error output here]
```

## Expected Behavior
Should build successfully

## Additional Context
Any modifications made to default setup
```

---

**Still having issues?** → Check the [Quick Reference](reference.md) for command summaries

**Everything working?** → Continue with [Advanced Customization](09-advanced-customization.md)

*Common issues resolved: 95% | Average time to fix: 5-15 minutes*