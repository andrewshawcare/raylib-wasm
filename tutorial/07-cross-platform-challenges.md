# 🛠️ Cross-Platform Challenges: Real-World Problem Solving

Cross-platform development isn't just about writing portable code - it's about solving the inevitable platform-specific issues that arise. Let's explore real challenges and their solutions, including the X11 dependency issue we encountered in this project.

## 🎯 The X11 Dependency Problem (Solved!)

### The Issue We Faced

When building for WebAssembly, we encountered this error:

```
CMake Error at /usr/share/cmake-3.28/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
  Could NOT find X11 (missing: X11_X11_LIB)
Call Stack (most recent call first):
  build-wasm/_deps/raylib-src/src/external/glfw/src/CMakeLists.txt:181 (find_package)
```

### 🤔 Why This Happened

**The Root Cause:**
```
Dependency Chain:
main.c → raylib → GLFW → X11 (Linux window system)
                     ↓
               WebAssembly doesn't need X11!
               (Uses browser canvas instead)
```

**The Problem:**
- **GLFW** (windowing library) was configured to require X11 on Linux
- **WebAssembly** doesn't need X11 (uses browser canvas)
- **CMake** was trying to find X11 libraries that aren't needed

### 🔧 The Solution

We solved this by configuring raylib platform-specifically in `CMakeLists.txt`:

```cmake
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    # Configure raylib for WebAssembly build
    set(PLATFORM "Web" CACHE STRING "Platform" FORCE)
    set(SUPPORT_X11 OFF CACHE BOOL "Support X11" FORCE)
    set(SUPPORT_WAYLAND OFF CACHE BOOL "Support Wayland" FORCE)
    
    include(FetchContent)
    FetchContent_Declare(
        raylib
        GIT_REPOSITORY https://github.com/raysan5/raylib.git
        GIT_TAG 5.5
    )
    FetchContent_MakeAvailable(raylib)
```

**Why This Works:**
1. **Platform Detection:** Detects Emscripten build environment
2. **Explicit Configuration:** Forces raylib to use Web platform
3. **Disable Desktop Features:** Turns off X11 and Wayland support
4. **Source Compilation:** Uses FetchContent for custom build

### 🧪 The Debug Process

**Step 1: Reproduce the Error**
```bash
./build-wasm.sh
# Error: Could NOT find X11
```

**Step 2: Understand the Dependency Chain**
```bash
# Examine the CMake error location
cat build-wasm/_deps/raylib-src/src/external/glfw/src/CMakeLists.txt
# Line 181: find_package(X11 REQUIRED)
```

**Step 3: Research Raylib Configuration**
```bash
# Check raylib documentation for platform options
grep -r "PLATFORM" build-wasm/_deps/raylib-src/
# Found: PLATFORM can be "Desktop", "Web", "Android", etc.
```

**Step 4: Test the Solution**
```bash
# Clean build directory
rm -rf build-wasm
# Add platform configuration to CMakeLists.txt
# Rebuild
./build-wasm.sh
# Success! ✅
```

## 🌐 Common Cross-Platform Challenges

### 1. Window System Dependencies

**The Challenge:**
Different platforms use different windowing systems:

```
Platform Window Systems:
┌─────────┬──────────────────┬─────────────────┐
│ Linux   │ X11, Wayland     │ Multiple options│
│ Windows │ Win32 API        │ Single system   │
│ macOS   │ Cocoa/AppKit     │ Single system   │
│ Web     │ Canvas/WebGL     │ Browser-managed │
└─────────┴──────────────────┴─────────────────┘
```

**Common Solutions:**
```cmake
# CMake platform detection
if(WIN32)
    set(PLATFORM_LIBS "gdi32 winmm")
elseif(APPLE)
    set(PLATFORM_LIBS "-framework Cocoa -framework OpenGL")
elseif(UNIX)
    find_package(X11 REQUIRED)
    set(PLATFORM_LIBS "${X11_LIBRARIES} pthread dl rt")
endif()

target_link_libraries(${PROJECT_NAME} ${PLATFORM_LIBS})
```

### 2. Graphics API Differences

**Desktop Graphics APIs:**
```c
// OpenGL (Linux/Windows/macOS)
#include <GL/gl.h>          // Linux
#include <OpenGL/gl.h>      // macOS  
#include <windows.h>        // Windows (before OpenGL)
#include <GL/gl.h>

// Platform-specific context creation
#ifdef _WIN32
    wglMakeCurrent(hdc, hglrc);
#elif __APPLE__
    [context makeCurrentContext];
#else  // Linux
    glXMakeCurrent(display, window, context);
#endif
```

**WebAssembly Graphics:**
```c
// WebGL (through Emscripten)
#ifdef EMSCRIPTEN
    #include <GLES2/gl2.h>     // OpenGL ES 2.0
    // Emscripten handles context automatically
#endif
```

### 3. File System Access

**Platform Differences:**
```c
// Path separators
#ifdef _WIN32
    #define PATH_SEP "\\"
    #define PATH_SEP_CHAR '\\'
#else
    #define PATH_SEP "/"
    #define PATH_SEP_CHAR '/'
#endif

// File paths
char config_path[256];
#ifdef _WIN32
    snprintf(config_path, sizeof(config_path), "%s\\config.txt", 
             getenv("APPDATA"));
#else
    snprintf(config_path, sizeof(config_path), "%s/.config/app/config.txt", 
             getenv("HOME"));
#endif
```

**WebAssembly Virtual File System:**
```c
#ifdef EMSCRIPTEN
    // Files must be preloaded or downloaded
    // --preload-file assets/ creates virtual filesystem
    FILE* file = fopen("assets/config.txt", "r");  // Virtual path
#else
    // Native file access
    FILE* file = fopen("/home/user/config.txt", "r");  // Real path
#endif
```

### 4. Audio System Differences

**Platform Audio APIs:**
```c
// ALSA (Linux)
#ifdef __linux__
    #include <alsa/asoundlib.h>
    snd_pcm_t* pcm_handle;
    snd_pcm_open(&pcm_handle, "default", SND_PCM_STREAM_PLAYBACK, 0);
#endif

// DirectSound (Windows)  
#ifdef _WIN32
    #include <dsound.h>
    IDirectSound8* directSound;
    DirectSoundCreate8(NULL, &directSound, NULL);
#endif

// Core Audio (macOS)
#ifdef __APPLE__
    #include <AudioToolbox/AudioToolbox.h>
    AudioQueueRef audioQueue;
    AudioQueueNewOutput(&format, callback, NULL, NULL, NULL, 0, &audioQueue);
#endif

// WebAudio (Browser)
#ifdef EMSCRIPTEN
    // Handled automatically by Emscripten/raylib
    // Uses Web Audio API under the hood
#endif
```

## 🔧 Cross-Platform Build System Solutions

### 1. CMake Platform Detection

**Robust Platform Detection:**
```cmake
# Detect platform early
if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    set(PLATFORM_WINDOWS TRUE)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    set(PLATFORM_MACOS TRUE)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(PLATFORM_LINUX TRUE)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    set(PLATFORM_WEB TRUE)
endif()

# Platform-specific configurations
if(PLATFORM_WINDOWS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
    add_definitions(-DPLATFORM_WINDOWS)
elseif(PLATFORM_MACOS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
    add_definitions(-DPLATFORM_MACOS)
elseif(PLATFORM_LINUX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
    add_definitions(-DPLATFORM_LINUX)
elseif(PLATFORM_WEB)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_GLFW=3")
    add_definitions(-DPLATFORM_WEB)
endif()
```

### 2. Conan Cross-Platform Packages

**Platform-Specific Dependencies:**
```ini
# conanfile.txt
[requires]
raylib/5.5

# Platform-specific requirements
[requires:linux]
xorg/system

[requires:windows]  
winsdk/[>=10.0]

[requires:macos]
# macOS dependencies handled by system

[requires:emscripten]
emsdk/3.1.73
```

### 3. Conditional Source Compilation

**Platform-Specific Source Files:**
```cmake
# Common source files
set(COMMON_SOURCES
    main.c
    game.c
    graphics.c
)

# Platform-specific sources
if(PLATFORM_WINDOWS)
    list(APPEND SOURCES platform/windows.c)
elseif(PLATFORM_LINUX)
    list(APPEND SOURCES platform/linux.c)
elseif(PLATFORM_MACOS)
    list(APPEND SOURCES platform/macos.c)
elseif(PLATFORM_WEB)
    list(APPEND SOURCES platform/web.c)
endif()

add_executable(${PROJECT_NAME} ${COMMON_SOURCES} ${SOURCES})
```

## 🧪 Testing Cross-Platform Builds

### 1. Docker for Linux Testing

**Ubuntu Testing Container:**
```dockerfile
FROM ubuntu:22.04

RUN apt update && apt install -y \
    build-essential \
    cmake \
    python3-pip \
    git

RUN pip3 install conan

WORKDIR /app
COPY . .

RUN ./build-native.sh
```

**Build and Test:**
```bash
docker build -t raylib-test .
docker run raylib-test
```

### 2. GitHub Actions CI/CD

**Cross-Platform Testing:**
```yaml
# .github/workflows/build.yml
name: Cross-Platform Build

on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        pip install conan
        conan profile detect --force
    
    - name: Build native
      run: ./build-native.sh
      shell: bash
    
    - name: Build WebAssembly  
      run: ./build-wasm.sh
      shell: bash
      if: matrix.os == 'ubuntu-latest'
```

### 3. Virtual Machine Testing

**VirtualBox/VMware Setup:**
```bash
# Test on different Linux distributions
vagrant init ubuntu/jammy64
vagrant up
vagrant ssh

# Inside VM
git clone <your-repo>
cd raylib-wasm
./build-native.sh
```

## 🐛 Common Platform-Specific Bugs

### 1. Endianness Issues

**Problem:**
```c
// May work on x86 but fail on ARM
uint32_t value = 0x12345678;
uint8_t* bytes = (uint8_t*)&value;
// bytes[0] might be 0x12 or 0x78 depending on endianness
```

**Solution:**
```c
#include <stdint.h>

// Use explicit byte operations
uint32_t pack_bytes(uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
    return ((uint32_t)a << 24) | ((uint32_t)b << 16) | 
           ((uint32_t)c << 8) | (uint32_t)d;
}

uint8_t get_byte(uint32_t value, int index) {
    return (value >> (8 * (3 - index))) & 0xFF;
}
```

### 2. Alignment Issues

**Problem:**
```c
struct BadStruct {
    char flag;       // 1 byte
    double value;    // 8 bytes - may need 8-byte alignment
};  // Size might be 9 or 16 bytes depending on platform
```

**Solution:**
```c
#include <stddef.h>

struct GoodStruct {
    double value;    // Put largest alignment first
    char flag;       // Smaller types follow
} __attribute__((packed));  // GCC
// or #pragma pack(1) for MSVC

// Check alignment at compile time
static_assert(sizeof(struct GoodStruct) == 9, "Unexpected struct size");
```

### 3. Path Length Limits

**Problem:**
```c
char path[256];  // May be too short on some systems
sprintf(path, "%s/%s", very_long_directory, filename);
```

**Solution:**
```c
#include <limits.h>

#ifdef PATH_MAX
    #define MAX_PATH_LENGTH PATH_MAX
#else
    #define MAX_PATH_LENGTH 4096  // Conservative fallback
#endif

char path[MAX_PATH_LENGTH];
int result = snprintf(path, sizeof(path), "%s/%s", directory, filename);
if (result >= sizeof(path)) {
    fprintf(stderr, "Path too long\n");
    return -1;
}
```

## 🎯 Cross-Platform Best Practices

### 1. Use Standard Libraries

**Prefer Standard C:**
```c
// ✅ Standard C - works everywhere
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// ❌ Platform-specific - creates dependencies
#include <windows.h>   // Windows only
#include <unistd.h>    // Unix only
```

### 2. Abstract Platform Differences

**Create Platform Abstraction Layer:**
```c
// platform.h
typedef struct {
    void (*init_window)(int width, int height);
    void (*destroy_window)(void);
    bool (*should_close)(void);
} PlatformAPI;

extern PlatformAPI platform;

// platform_web.c
static void web_init_window(int width, int height) {
    emscripten_set_canvas_element_size("#canvas", width, height);
}

PlatformAPI platform = {
    .init_window = web_init_window,
    .destroy_window = web_destroy_window,
    .should_close = web_should_close
};
```

### 3. Test Early and Often

**Continuous Integration:**
```yaml
# Test on multiple platforms with every commit
- Linux (Ubuntu, CentOS, Arch)
- Windows (MinGW, MSVC, Clang)
- macOS (Intel, Apple Silicon)
- WebAssembly (Chrome, Firefox, Safari)
```

### 4. Use Feature Detection

**Runtime Feature Detection:**
```c
bool has_feature(const char* feature) {
#ifdef EMSCRIPTEN
    return EM_ASM_INT({
        return typeof window[UTF8ToString($0)] !== 'undefined';
    }, feature);
#else
    // Native feature detection
    return check_native_feature(feature);
#endif
}

// Usage
if (has_feature("WebGL2")) {
    use_webgl2_features();
} else {
    use_fallback_rendering();
}
```

## 🎓 Key Takeaways

**Cross-Platform Development Principles:**

1. **Expect Platform Differences** - Each platform has unique requirements
2. **Use Abstraction Layers** - Hide platform details behind clean APIs
3. **Test Continuously** - Build and test on all target platforms
4. **Document Solutions** - Keep track of solved issues for future reference

**Tools That Help:**
- **CMake** - Cross-platform build system
- **Conan** - Cross-platform package management
- **Docker** - Consistent build environments
- **CI/CD** - Automated cross-platform testing

**Skills Gained:**
- **Problem diagnosis** - Debugging platform-specific issues
- **Build system mastery** - Managing complex dependencies
- **Platform abstraction** - Writing portable code
- **Testing strategies** - Ensuring cross-platform compatibility

---

**Ready to optimize your workflow?** → [Development Workflow](08-development-workflow.md)

**Want to dive deeper into build configuration?** → [Advanced Customization](09-advanced-customization.md)

*Time to read: ~20 minutes | Difficulty: ⭐⭐⭐⭐☆*