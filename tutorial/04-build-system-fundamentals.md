# 🔧 Build System Fundamentals: CMake + Conan

Ever wondered why we don't just run `gcc main.c -o program`? Welcome to the world of professional C development! Let's explore the build system that powers modern C projects.

## 🤔 Why Not Just Use GCC Directly?

### The Old Way (Doesn't Scale)
```bash
# Simple programs - this works
gcc main.c -o program

# Real projects - this becomes a nightmare
gcc main.c graphics.c audio.c network.c input.c -lraylib -lglfw -lGL -lm -lpthread -ldl -lrt -lX11 -o program
```

### The Problems with Manual Compilation

**🔗 Dependency Hell:**
- Where is raylib installed? `/usr/local/lib`? `/opt/homebrew/lib`?
- Which version do we need? How do we ensure consistency?
- What about transitive dependencies? (raylib needs GLFW, GLFW needs X11...)

**🌐 Cross-Platform Nightmare:**
```bash
# Linux
gcc main.c -lraylib -lGL -lX11 -lpthread

# Windows  
gcc main.c -lraylib -lopengl32 -lgdi32 -lwinmm

# macOS
gcc main.c -lraylib -framework OpenGL -framework Cocoa

# WebAssembly
emcc main.c -s USE_GLFW=3 -s WASM=1 --preload-file assets/
```

## 🏗️ Enter Modern Build Systems

### Our Two-Tool Solution

```
🔧 CMake: Build System Generator
   ↓
📦 Conan: Package Manager
   ↓
🎯 Cross-Platform Magic
```

**CMake** handles *how* to build  
**Conan** handles *what* to build with

## 📦 Conan: The Package Manager

Think of Conan as "npm for C/C++" or "pip for Python":

### Our `conanfile.txt`
```ini
[requires]
emsdk/3.1.73     # Emscripten SDK for WebAssembly
raylib/5.5       # Graphics library

[generators]
CMakeDeps        # Generate CMake find_package() files
CMakeToolchain   # Generate CMake toolchain
```

### 🎯 What Conan Does for Us

**Dependency Resolution:**
```bash
conan install . --build=missing
```

This single command:
1. **Downloads** raylib and all its dependencies
2. **Compiles** them for your specific platform
3. **Generates** CMake configuration files
4. **Handles** version conflicts automatically

**Generated Files:**
```
build/Release/generators/
├── conan_toolchain.cmake    # Compiler settings
├── raylib-config.cmake      # Find raylib
├── glfw-config.cmake        # Find GLFW (raylib dependency)
└── conanbuild.sh            # Environment setup
```

### 🌐 Cross-Platform Magic

The same `conanfile.txt` works everywhere:

```bash
# Linux
conan install . --profile:host=linux-x86_64

# Windows  
conan install . --profile:host=windows-x86_64

# WebAssembly
conan install . --profile:host=emscripten-wasm
```

## 🔨 CMake: The Build System Generator

CMake doesn't compile your code directly - it generates build files for your platform:

```
CMakeLists.txt → [CMake] → Platform-specific build files
                    ↓
           ┌────────────────────────────┐
           │ Linux: Makefiles           │
           │ Windows: Visual Studio     │
           │ macOS: Xcode              │
           │ WebAssembly: Emscripten   │
           └────────────────────────────┘
```

### Our `CMakeLists.txt` Breakdown

```cmake
cmake_minimum_required(VERSION 3.15)
project(raylib-wasm C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
```

**Why C99?**
- **Modern enough:** Supports `//` comments, variable declarations anywhere
- **Portable enough:** Works on embedded systems and older compilers
- **Stable:** Well-established standard without cutting-edge features

### 🔧 Compiler Configuration

```cmake
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DNDEBUG")
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W4")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /O2 /DNDEBUG")
endif()
```

**Compiler Flags Explained:**
- **`-Wall -Wextra`:** Enable helpful warnings
- **`-Wpedantic`:** Strict standard compliance
- **`-O3`:** Maximum optimization for release builds
- **`-g -O0`:** Debug symbols, no optimization for debugging

### 🎯 The Platform Detection Logic

```cmake
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    # WebAssembly configuration
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
else()
    # Native builds use Conan-provided raylib
    find_package(raylib REQUIRED)
endif()
```

**Why Different Approaches?**

**For WebAssembly (FetchContent):**
- ✅ Source compilation needed for Emscripten
- ✅ Platform-specific optimizations
- ✅ Custom configuration (disable X11)

**For Native (Conan):**
- ✅ Pre-compiled binaries (faster builds)
- ✅ Version management
- ✅ Dependency resolution

### 🌐 WebAssembly-Specific Configuration

```cmake
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_GLFW=3")
    
    set(EMSCRIPTEN_LINK_FLAGS "-s USE_GLFW=3 -s ASSERTIONS=1 -s WASM=1 -s ASYNCIFY -s GL_ENABLE_GET_PROC_ADDRESS=1")
    
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -O3")
    else()
        set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -O1")
    endif()
    
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SUFFIX ".html"
        LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS}"
    )
endif()
```

**Emscripten Flags Explained:**
- **`USE_GLFW=3`:** Use GLFW 3 for window management
- **`WASM=1`:** Generate WebAssembly (not just JavaScript)
- **`ASYNCIFY`:** Enable asynchronous operations
- **`ASSERTIONS=1`:** Runtime checks (disable in production)
- **`SUFFIX ".html"`:** Generate HTML wrapper file

## 🔄 The Build Process Flow

### Native Build Process
```
1. conan install .
   ├── Downloads raylib from ConanCenter
   ├── Compiles for your platform
   └── Generates CMake config files

2. cmake .. -DCMAKE_TOOLCHAIN_FILE=../build/Release/generators/conan_toolchain.cmake
   ├── Reads CMakeLists.txt
   ├── Finds raylib via Conan-generated files
   └── Generates Makefiles (on Linux)

3. make -j$(nproc)
   ├── Compiles main.c
   ├── Links with raylib
   └── Creates executable
```

### WebAssembly Build Process
```
1. conan install . (for emsdk only)
   └── Downloads Emscripten SDK

2. source emsdk/emsdk_env.sh
   └── Sets up Emscripten environment

3. emcmake cmake .. -DUSE_CONAN_RAYLIB=OFF
   ├── FetchContent downloads raylib source
   ├── Configures for WebAssembly target
   └── Generates Emscripten-compatible Makefiles

4. emmake make -j$(nproc)
   ├── Compiles main.c to WASM
   ├── Compiles raylib to WASM
   └── Creates .html, .js, .wasm files
```

## 🧪 Understanding Through Experimentation

### 🎯 **Experiment 1: Manual Dependency Tracking**

See what happens without Conan:

```bash
# Try building without Conan (this will fail!)
mkdir manual-build && cd manual-build
cmake .. -DUSE_CONAN_RAYLIB=OFF
```

**Expected Error:**
```
CMake Error: Could not find raylib
```

**Why?** CMake doesn't know where to find raylib!

### 🎯 **Experiment 2: Verbose Build Output**

See exactly what the build system does:

```bash
cd build-native
make VERBOSE=1
```

**You'll see the actual gcc commands:**
```bash
/usr/bin/cc -O3 -DNDEBUG -Wall -Wextra -Wpedantic -I/path/to/raylib/include -c main.c -o main.c.o
/usr/bin/cc main.c.o -lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -o raylib-wasm
```

### 🎯 **Experiment 3: Cross-Compilation**

Try building for a different architecture:

```bash
# Install cross-compilation tools (on Ubuntu)
sudo apt install gcc-aarch64-linux-gnu

# Create cross-compilation profile
conan profile detect --force
# Edit ~/.conan2/profiles/default and change arch to armv8
```

## 🚀 Advanced Build System Concepts

### 🎯 **Generator Expressions**

CMake's conditional compilation syntax:

```cmake
target_compile_definitions(${PROJECT_NAME} PRIVATE
    $<$<CONFIG:Debug>:DEBUG_MODE>
    $<$<CONFIG:Release>:RELEASE_MODE>
)
```

This adds `-DDEBUG_MODE` only in debug builds.

### 🎯 **FetchContent vs find_package**

**FetchContent (Source-based):**
```cmake
FetchContent_Declare(
    raylib
    GIT_REPOSITORY https://github.com/raysan5/raylib.git
    GIT_TAG 5.5
)
FetchContent_MakeAvailable(raylib)
```

**find_package (Binary-based):**
```cmake
find_package(raylib REQUIRED)
target_link_libraries(${PROJECT_NAME} raylib)
```

**When to use which?**
- **FetchContent:** WebAssembly, embedded systems, custom builds
- **find_package:** Desktop applications, standard configurations

### 🎯 **Cache Variables**

```cmake
set(PLATFORM "Web" CACHE STRING "Platform" FORCE)
```

- **CACHE:** Persists between CMake runs
- **STRING:** Type hint for CMake GUIs
- **FORCE:** Override existing cache values

## 🎓 Modern C Build Best Practices

### ✅ **Do This**
```cmake
# ✅ Specify minimum version
cmake_minimum_required(VERSION 3.15)

# ✅ Use modern target-based commands
target_link_libraries(${PROJECT_NAME} raylib)

# ✅ Set properties on targets, not globally
set_target_properties(${PROJECT_NAME} PROPERTIES C_STANDARD 99)

# ✅ Use generator expressions for conditional logic
target_compile_definitions(${PROJECT_NAME} PRIVATE
    $<$<PLATFORM_ID:Windows>:WINDOWS_BUILD>
)
```

### ❌ **Avoid This**
```cmake
# ❌ Ancient CMake patterns
link_libraries(raylib)          # Global scope pollution
include_directories(/usr/include) # Global include paths
add_definitions(-DDEBUG)        # Global definitions

# ❌ Hardcoded paths
set(RAYLIB_PATH /usr/local/lib/raylib)
```

## 🔧 Troubleshooting Build Issues

### **Common Problem: "Could not find raylib"**

**Diagnosis:**
```bash
# Check if Conan generated the files
ls build/Release/generators/

# Check CMake's find path
cmake .. --debug-output
```

**Solution:**
```bash
# Regenerate Conan files
rm -rf build/
conan install . --build=missing
```

### **Common Problem: "Wrong Architecture"**

**Diagnosis:**
```bash
file build-native/raylib-wasm
# Should show correct architecture (x86_64, ARM, etc.)
```

**Solution:**
```bash
# Clean and rebuild
./cleanup.sh
conan profile detect --force  # Regenerate profile
./build-native.sh
```

## 🎯 Key Takeaways

**Why This Build System is Professional:**

1. **🌐 Cross-Platform:** Same files work everywhere
2. **📦 Dependency Management:** Automatic resolution and versioning
3. **🔧 Configurable:** Debug vs Release, different platforms
4. **📈 Scalable:** Handles projects from 1 to 1,000,000 files
5. **🤝 Collaborative:** Team members get identical builds

**Industry Usage:**
- **Game Studios:** Unreal Engine, many indie games
- **Tech Companies:** Google, Microsoft, Facebook C++ projects
- **Embedded:** IoT devices, automotive systems
- **Finance:** High-frequency trading systems

---

**Ready to build natively?** → [Native Development](05-native-development.md)

**Want to explore WebAssembly?** → [Web Development](06-web-development.md)

*Time to read: ~15 minutes | Difficulty: ⭐⭐⭐☆☆*