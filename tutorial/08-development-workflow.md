# 🔄 Development Workflow: Rapid Iteration Mastery

Professional developers don't manually rebuild after every change. Let's explore the automated workflows that make development fast and enjoyable, featuring our powerful `watch.sh` script.

## 🚀 The Power of `watch.sh`

### What is File Watching?

**File watching** automatically rebuilds and runs your application whenever source files change:

```
Traditional Workflow:
Edit code → Save → Run build script → Run application → Repeat
   ↓ 30 seconds per cycle ↓

Automated Workflow:  
Edit code → Save → [Automatic rebuild + run]
   ↓ 3 seconds per cycle ↓
```

**Time Savings:**
- **Manual process:** 30 seconds per change
- **Automated process:** 3 seconds per change
- **100 changes/day:** Save 45 minutes daily!

### 🎯 Our Watch Script Features

```bash
./watch.sh
```

**What it does:**
1. **Builds both versions** initially (native + WebAssembly)
2. **Watches main.c** for changes using `inotifywait`
3. **Auto-rebuilds** both versions when files change
4. **Auto-runs** native version in background
5. **Auto-serves** WebAssembly version on localhost:8080
6. **Handles cleanup** when interrupted (Ctrl+C)

## 🔍 Watch Script Deep Dive

### File Watching with inotify

```bash
# Monitor main.c for modifications
inotifywait -m -e modify main.c |
while read path action file; do
    echo "Change detected in main.c!"
    # Rebuild both versions
done
```

**inotify Events:**
```bash
-e modify    # File content changed
-e create    # New file created
-e delete    # File deleted
-e move      # File moved/renamed
-e attrib    # Permissions changed
```

**Why inotify?**
- **Efficient:** Kernel-level file monitoring
- **Immediate:** No polling delays
- **Reliable:** Works with all editors (VS Code, vim, nano)

### Automatic Dependency Installation

```bash
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
        error_exit "Could not install inotify-tools automatically."
    fi
fi
```

**Cross-Platform Package Management:**
- **Ubuntu/Debian:** `apt install inotify-tools`
- **Fedora/CentOS:** `dnf install inotify-tools`
- **Arch Linux:** `pacman -S inotify-tools`
- **macOS:** `brew install fswatch` (alternative tool)

### Process Management

```bash
# Cleanup function that runs on script exit
cleanup_on_exit() {
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

# Set up trap to run cleanup when script is interrupted
trap cleanup_on_exit SIGINT SIGTERM
```

**Signal Handling:**
- **SIGINT:** Ctrl+C interrupt
- **SIGTERM:** Termination request
- **EXIT:** Script exits normally

## 🔧 Advanced Development Workflows

### 1. Multiple File Watching

**Watch Multiple Files:**
```bash
# Watch all C source files
inotifywait -m -r -e modify \
    --include='.*\.(c|h)$' \
    ./ |
while read directory event filename; do
    echo "Changed: $directory$filename"
    ./build-native.sh
done
```

**Watch Project Structure:**
```bash
# Watch source files and build config
inotifywait -m -e modify \
    main.c \
    CMakeLists.txt \
    conanfile.txt |
while read path action file; do
    echo "Rebuilding due to $file change..."
    
    if [[ "$file" == "conanfile.txt" ]]; then
        # Dependencies changed - clean rebuild
        ./cleanup.sh
    fi
    
    ./build-native.sh
done
```

### 2. Conditional Rebuilding

**Smart Rebuild Logic:**
```bash
while read path action file; do
    echo "Change detected in $file"
    
    case "$file" in
        *.c|*.h)
            echo "Source file changed - building native..."
            ./build-native.sh
            ;;
        CMakeLists.txt)
            echo "Build config changed - clean rebuild..."
            ./cleanup.sh
            ./build-native.sh
            ./build-wasm.sh
            ;;
        conanfile.txt)
            echo "Dependencies changed - full rebuild..."
            ./cleanup.sh
            rm -rf ~/.conan2/p/*/  # Clear Conan cache
            ./build-native.sh
            ./build-wasm.sh
            ;;
    esac
done
```

### 3. Build Status Notifications

**Desktop Notifications (Linux):**
```bash
notify_build_result() {
    local status=$1
    local message=$2
    
    if command -v notify-send &> /dev/null; then
        if [ "$status" = "success" ]; then
            notify-send "Build Success" "$message" --icon=dialog-information
        else
            notify-send "Build Failed" "$message" --icon=dialog-error
        fi
    fi
}

# Usage in build loop
if ./build-native.sh; then
    notify_build_result "success" "Native build completed successfully"
else
    notify_build_result "failure" "Native build failed - check console"
fi
```

**macOS Notifications:**
```bash
notify_macos() {
    local title=$1
    local message=$2
    osascript -e "display notification \"$message\" with title \"$title\""
}
```

**Windows Notifications (WSL):**
```bash
notify_windows() {
    local message=$1
    powershell.exe -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$message', 'Build Status')}"
}
```

## 🎮 IDE Integration

### VS Code Integration

**Launch Configuration (`.vscode/launch.json`):**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Native",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build-native/raylib-wasm",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "preLaunchTask": "build-native"
        }
    ]
}
```

**Tasks Configuration (`.vscode/tasks.json`):**
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build-native",
            "type": "shell",
            "command": "./build-native.sh",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": "$gcc"
        },
        {
            "label": "build-wasm",
            "type": "shell",
            "command": "./build-wasm.sh",
            "group": "build"
        },
        {
            "label": "watch",
            "type": "shell",
            "command": "./watch.sh",
            "group": "build",
            "isBackground": true
        }
    ]
}
```

**Settings (`.vscode/settings.json`):**
```json
{
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools",
    "C_Cpp.default.compilerPath": "/usr/bin/gcc",
    "C_Cpp.default.cStandard": "c99",
    "files.associations": {
        "*.h": "c"
    },
    "cmake.buildDirectory": "${workspaceFolder}/build-native"
}
```

### CLion Integration

**CMake Profiles:**
```cmake
# Add to CMakeLists.txt for CLion
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)  # For code completion
endif()
```

**Run Configurations:**
1. **Native Debug:** Target `raylib-wasm`, Working Directory: `build-native`
2. **WebAssembly:** External Tool, Command: `./build-wasm.sh`
3. **Watch Mode:** External Tool, Command: `./watch.sh`

### Vim/Neovim Integration

**Build Commands (`.vimrc`):**
```vim
" Quick build commands
nnoremap <F5> :!./build-native.sh<CR>
nnoremap <F6> :!./build-wasm.sh<CR>
nnoremap <F7> :!./watch.sh<CR>

" Async build with quickfix
command! BuildNative :AsyncRun ./build-native.sh
command! BuildWasm :AsyncRun ./build-wasm.sh
```

## 🧪 Advanced Workflow Techniques

### 1. Parallel Development

**Multiple Terminals Setup:**
```bash
# Terminal 1: File watcher
./watch.sh

# Terminal 2: Manual testing
cd build-native && ./raylib-wasm

# Terminal 3: Web server monitoring
cd build-wasm && python3 -m http.server 8080

# Terminal 4: Git operations
git status
git add main.c
git commit -m "Update ball physics"
```

**tmux Session Setup:**
```bash
# Create development session
tmux new-session -d -s raylib

# Split into panes
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux split-window -v

# Run commands in each pane
tmux send-keys -t 0 './watch.sh' Enter
tmux send-keys -t 1 'cd build-native' Enter
tmux send-keys -t 2 'cd build-wasm && python3 -m http.server 8080' Enter
tmux send-keys -t 3 'git status' Enter

# Attach to session
tmux attach-session -t raylib
```

### 2. Hot Reloading for WebAssembly

**Live Reload Script:**
```javascript
// Add to raylib-wasm.html
function setupLiveReload() {
    const eventSource = new EventSource('/events');
    eventSource.onmessage = function(event) {
        if (event.data === 'reload') {
            location.reload();
        }
    };
}

if (window.location.hostname === 'localhost') {
    setupLiveReload();
}
```

**Simple Server with Live Reload:**
```python
#!/usr/bin/env python3
import http.server
import socketserver
import threading
import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class ReloadHandler(FileSystemEventHandler):
    def __init__(self, clients):
        self.clients = clients
    
    def on_modified(self, event):
        if event.src_path.endswith('.wasm'):
            for client in self.clients:
                client.send_reload()

class HTTPHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='build-wasm', **kwargs)

# Usage: python3 live-server.py
```

### 3. Performance Monitoring

**Automatic Profiling:**
```bash
# Add to watch loop
profile_build() {
    echo "Profiling build performance..."
    
    start_time=$(date +%s%3N)
    ./build-native.sh
    end_time=$(date +%s%3N)
    
    build_time=$((end_time - start_time))
    echo "Build completed in ${build_time}ms"
    
    # Log to file for analysis
    echo "$(date): ${build_time}ms" >> build-times.log
}
```

**Memory Usage Monitoring:**
```c
// Add to main.c for development builds
#ifdef DEBUG
void print_memory_usage() {
    FILE* status = fopen("/proc/self/status", "r");
    char line[128];
    
    while (fgets(line, sizeof(line), status)) {
        if (strncmp(line, "VmRSS:", 6) == 0) {
            printf("[DEBUG] Memory usage: %s", line + 6);
            break;
        }
    }
    fclose(status);
}

// Call periodically in game loop
static int frame_count = 0;
if (++frame_count % 300 == 0) {  // Every 5 seconds at 60fps
    print_memory_usage();
}
#endif
```

## 🎯 Workflow Optimization Tips

### 1. Incremental Compilation

**Make Selective Rebuilds:**
```bash
# Only rebuild if source newer than executable
if [ main.c -nt build-native/raylib-wasm ]; then
    echo "Source changed, rebuilding..."
    ./build-native.sh
else
    echo "No changes detected, skipping build"
fi
```

**CMake's Built-in Dependency Tracking:**
```cmake
# CMake automatically tracks dependencies
# Only modified files are recompiled
add_executable(${PROJECT_NAME} main.c game.c graphics.c)

# Explicit dependencies for headers
target_include_directories(${PROJECT_NAME} PRIVATE include/)
```

### 2. Build Caching

**Conan Cache Management:**
```bash
# Preserve Conan packages between rebuilds
export CONAN_USER_HOME="$HOME/.conan-cache"

# Clean only build artifacts, not downloads
cleanup_build_only() {
    rm -rf build-native build-wasm
    # Keep ~/.conan2/p/ for faster subsequent builds
}
```

**ccache for Faster Compilation:**
```bash
# Install ccache
sudo apt install ccache

# Configure CMake to use ccache
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache

# Check cache statistics
ccache -s
```

### 3. Resource Management

**Automatic Cleanup:**
```bash
# Add to watch script exit handler
cleanup_resources() {
    # Kill background processes
    pkill -f "raylib-wasm"
    pkill -f "python3 -m http.server"
    
    # Clean temporary files
    rm -f /tmp/raylib-*
    
    # Reset terminal
    stty sane
    
    echo "Resources cleaned up"
}
```

## 🎓 Key Takeaways

**Development Workflow Benefits:**
- ✅ **10x faster iteration** - Immediate feedback on changes
- ✅ **Reduced cognitive load** - No manual build steps to remember
- ✅ **Professional practice** - Industry-standard development workflow
- ✅ **Error catching** - Immediate notification of build failures

**Tools Mastered:**
- **File watching** - `inotifywait`, `fswatch`
- **Process management** - Signal handling, background processes
- **IDE integration** - VS Code, CLion, Vim configurations
- **Automation** - Scripts, notifications, monitoring

**Professional Skills:**
- **Rapid prototyping** - Quick experimentation cycles
- **Development environment setup** - Optimized toolchains
- **Process optimization** - Identifying and eliminating bottlenecks
- **Tool integration** - Connecting multiple development tools

---

**Ready to customize your build system?** → [Advanced Customization](09-advanced-customization.md)

**Want to expand the project?** → [Project Expansion](10-project-expansion.md)

*Time to read: ~15 minutes | Difficulty: ⭐⭐⭐☆☆*