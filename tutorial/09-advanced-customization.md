# ⚡ Advanced Customization: Build System Mastery

Ready to unlock the full power of our build system? Let's explore advanced configurations, optimizations, and customizations that professional developers use.

## 🎯 Advanced CMake Configuration

### Custom Build Types

**Create Custom Build Configurations:**
```cmake
# Add to CMakeLists.txt after project()
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;Profile;Shipping" CACHE STRING "" FORCE)

# Profile build (optimized with debug info)
set(CMAKE_C_FLAGS_PROFILE "-O2 -g -DPROFILE_BUILD")
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "")

# Shipping build (maximum optimization, no debug)
set(CMAKE_C_FLAGS_SHIPPING "-O3 -DNDEBUG -DSHIPPING_BUILD -flto")
set(CMAKE_EXE_LINKER_FLAGS_SHIPPING "-flto")
```

**Usage:**
```bash
# Profile build
cmake .. -DCMAKE_BUILD_TYPE=Profile
make

# Shipping build
cmake .. -DCMAKE_BUILD_TYPE=Shipping
make
```

### Compiler-Specific Optimizations

**GCC/Clang Advanced Flags:**
```cmake
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    # Architecture-specific optimizations
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native -mtune=native")
    
    # Enable all warnings
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic -Wformat=2")
    
    # Security hardening
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstack-protector-strong -D_FORTIFY_SOURCE=2")
    
    # Link-time optimization (LTO)
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto")
    endif()
endif()
```

**MSVC Advanced Flags:**
```cmake
if(MSVC)
    # Enable all useful warnings
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W4 /WX")
    
    # Optimization flags
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /O2 /Ob2 /DNDEBUG")
    
    # Whole program optimization
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /GL")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /LTCG")
endif()
```

### Feature Detection and Options

**CMake Options for User Configuration:**
```cmake
# Add these after project() declaration
option(ENABLE_PROFILING "Enable performance profiling" OFF)
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)
option(ENABLE_UBSAN "Enable UBSanitizer" OFF)
option(ENABLE_TRACY "Enable Tracy profiler integration" OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Apply options
if(ENABLE_PROFILING)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pg")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pg")
endif()

if(ENABLE_ASAN)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
endif()

if(ENABLE_UBSAN)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=undefined")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=undefined")
endif()
```

**Usage:**
```bash
# Enable AddressSanitizer for memory debugging
cmake .. -DENABLE_ASAN=ON -DCMAKE_BUILD_TYPE=Debug

# Enable profiling
cmake .. -DENABLE_PROFILING=ON

# Enable multiple options
cmake .. -DENABLE_ASAN=ON -DENABLE_UBSAN=ON -DCMAKE_BUILD_TYPE=Debug
```

## 🔧 Advanced Conan Configuration

### Custom Conan Profiles

**Create Performance Profile (`~/.conan2/profiles/performance`):**
```ini
[settings]
os=Linux
arch=x86_64
compiler=gcc
compiler.version=13
compiler.libcxx=libstdc++11
build_type=Release

[options]
raylib:shared=False
raylib:use_external_glfw=False

[conf]
tools.cmake.cmaketoolchain:generator=Ninja
tools.build:compiler_executables={"c": "/usr/bin/gcc-13", "cpp": "/usr/bin/g++-13"}

[buildenv]
CFLAGS=-O3 -march=native -flto
CXXFLAGS=-O3 -march=native -flto
```

**Create Debug Profile (`~/.conan2/profiles/debug`):**
```ini
[settings]
os=Linux
arch=x86_64
compiler=gcc
compiler.version=13
compiler.libcxx=libstdc++11
build_type=Debug

[options]
raylib:shared=False

[conf]
tools.cmake.cmaketoolchain:generator=Unix Makefiles

[buildenv]
CFLAGS=-O0 -g3 -fsanitize=address
CXXFLAGS=-O0 -g3 -fsanitize=address
LDFLAGS=-fsanitize=address
```

**Usage:**
```bash
# Use custom profiles
conan install . --profile:build=default --profile:host=performance
conan install . --profile:build=default --profile:host=debug
```

### Custom Conanfile for Advanced Dependencies

**Create `conanfile.py` for Advanced Configuration:**
```python
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps, cmake_layout

class RaylibWasmConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "enable_tracy": [True, False],
        "enable_profiling": [True, False],
        "raylib_version": ["5.5", "5.0", "4.5"]
    }
    default_options = {
        "enable_tracy": False,
        "enable_profiling": False,
        "raylib_version": "5.5"
    }
    
    def requirements(self):
        self.requires(f"raylib/{self.options.raylib_version}")
        
        if self.settings.os != "Emscripten":
            if self.options.enable_tracy:
                self.requires("tracy/0.9.1")
            if self.options.enable_profiling:
                self.requires("gperftools/2.10")
    
    def layout(self):
        cmake_layout(self)
    
    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        
        tc = CMakeToolchain(self)
        tc.variables["ENABLE_TRACY"] = self.options.enable_tracy
        tc.variables["ENABLE_PROFILING"] = self.options.enable_profiling
        tc.generate()
```

**Usage:**
```bash
# Install with Tracy profiler
conan install . -o enable_tracy=True

# Install with profiling support
conan install . -o enable_profiling=True

# Use different raylib version
conan install . -o raylib_version=5.0
```

## 🚀 Emscripten Advanced Configuration

### Custom Emscripten Flags

**Add Advanced WebAssembly Configuration:**
```cmake
if(EMSCRIPTEN)
    # Memory configuration
    set(EMSCRIPTEN_MEMORY_FLAGS "")
    list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s INITIAL_MEMORY=33554432")  # 32MB
    list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s MAXIMUM_MEMORY=268435456") # 256MB max
    list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s ALLOW_MEMORY_GROWTH=1")
    
    # Threading support (experimental)
    if(ENABLE_THREADING)
        list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s USE_PTHREADS=1")
        list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s PTHREAD_POOL_SIZE=4")
        list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s SHARED_MEMORY=1")
    endif()
    
    # SIMD support
    if(ENABLE_SIMD)
        list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-msimd128")
        list(APPEND EMSCRIPTEN_MEMORY_FLAGS "-s SIMD=1")
    endif()
    
    # Debug vs Release flags
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "-s ASSERTIONS=2")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "-s SAFE_HEAP=1")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "-g4")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "--source-map-base=/")
    else()
        list(APPEND EMSCRIPTEN_LINK_FLAGS "-s ASSERTIONS=0")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "-O3")
        list(APPEND EMSCRIPTEN_LINK_FLAGS "--closure 1")
    endif()
    
    # Combine all flags
    string(JOIN " " ALL_EMSCRIPTEN_FLAGS ${EMSCRIPTEN_LINK_FLAGS} ${EMSCRIPTEN_MEMORY_FLAGS})
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "${ALL_EMSCRIPTEN_FLAGS}")
endif()
```

### WebAssembly Size Optimization

**Minimize WASM Binary Size:**
```cmake
if(EMSCRIPTEN AND CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    # Aggressive size optimization
    set(SIZE_FLAGS "")
    list(APPEND SIZE_FLAGS "-Oz")                    # Optimize for size
    list(APPEND SIZE_FLAGS "-s MINIMAL_RUNTIME=1")   # Minimal JS runtime
    list(APPEND SIZE_FLAGS "-s TEXTDECODER=0")       # Disable text decoder
    list(APPEND SIZE_FLAGS "-s MODULARIZE=1")        # Modular output
    list(APPEND SIZE_FLAGS "--closure 1")            # Google Closure compiler
    list(APPEND SIZE_FLAGS "-s ELIMINATE_DUPLICATE_FUNCTIONS=1")
    
    string(JOIN " " SIZE_OPTIMIZATION_FLAGS ${SIZE_FLAGS})
    set_target_properties(${PROJECT_NAME} PROPERTIES 
        LINK_FLAGS "${SIZE_OPTIMIZATION_FLAGS}")
endif()
```

## 🧪 Testing and Quality Assurance

### Automated Testing Integration

**Add CTest Support:**
```cmake
# Add after project() declaration
enable_testing()

# Simple functionality test
add_test(NAME basic_run 
         COMMAND ${PROJECT_NAME}
         WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
set_tests_properties(basic_run PROPERTIES TIMEOUT 10)

# Memory test with Valgrind
find_program(VALGRIND_EXECUTABLE valgrind)
if(VALGRIND_EXECUTABLE AND NOT EMSCRIPTEN)
    add_test(NAME memory_check
             COMMAND ${VALGRIND_EXECUTABLE} 
                     --leak-check=full 
                     --error-exitcode=1 
                     $<TARGET_FILE:${PROJECT_NAME}>)
    set_tests_properties(memory_check PROPERTIES TIMEOUT 30)
endif()

# Performance benchmark
add_test(NAME performance_test
         COMMAND timeout 5 $<TARGET_FILE:${PROJECT_NAME}>)
```

**Run Tests:**
```bash
# Build and run tests
cmake .. -DCMAKE_BUILD_TYPE=Debug
make
ctest --verbose

# Run specific test
ctest -R memory_check --verbose

# Run tests in parallel
ctest -j$(nproc)
```

### Static Analysis Integration

**Add Clang Static Analyzer:**
```cmake
find_program(CLANG_ANALYZER scan-build)
if(CLANG_ANALYZER)
    add_custom_target(analyze
        COMMAND ${CLANG_ANALYZER} --status-bugs make
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running static analysis")
endif()
```

**Add Cppcheck:**
```cmake
find_program(CPPCHECK_EXECUTABLE cppcheck)
if(CPPCHECK_EXECUTABLE)
    add_custom_target(cppcheck
        COMMAND ${CPPCHECK_EXECUTABLE}
                --enable=all
                --std=c99
                --verbose
                --quiet
                ${CMAKE_SOURCE_DIR}/main.c
        COMMENT "Running cppcheck")
endif()
```

**Usage:**
```bash
# Run static analysis
make analyze

# Run cppcheck
make cppcheck
```

## 📊 Performance Monitoring

### Tracy Profiler Integration

**Add Tracy Support:**
```cmake
option(ENABLE_TRACY "Enable Tracy profiler" OFF)

if(ENABLE_TRACY AND NOT EMSCRIPTEN)
    find_package(tracy REQUIRED)
    target_link_libraries(${PROJECT_NAME} tracy::tracy)
    target_compile_definitions(${PROJECT_NAME} PRIVATE TRACY_ENABLE)
endif()
```

**Use in Code:**
```c
#ifdef TRACY_ENABLE
#include <tracy/TracyC.h>
#else
#define TracyCZone(x, y)
#define TracyCZoneEnd(x)
#define TracyCFrameMark
#endif

void UpdateBall(Ball *ball, const int screenWidth, const int screenHeight) {
    TracyCZone(update_zone, true);
    
    // ... ball update logic ...
    
    TracyCZoneEnd(update_zone);
}

int main(void) {
    // ... initialization ...
    
    while (!WindowShouldClose()) {
        TracyCFrameMark;  // Mark frame boundaries
        
        // ... game loop ...
    }
    
    return 0;
}
```

### Custom Profiling Macros

**Create Profiling System:**
```c
// profiler.h
#ifndef PROFILER_H
#define PROFILER_H

#include <time.h>
#include <stdio.h>

#ifdef ENABLE_PROFILING
    typedef struct {
        clock_t start_time;
        const char* name;
    } ProfileTimer;
    
    #define PROFILE_START(name) \
        ProfileTimer timer_##name = {clock(), #name}
    
    #define PROFILE_END(name) do { \
        clock_t end_time = clock(); \
        double elapsed = ((double)(end_time - timer_##name.start_time)) / CLOCKS_PER_SEC * 1000.0; \
        printf("[PROFILE] %s: %.3fms\n", timer_##name.name, elapsed); \
    } while(0)
    
    #define PROFILE_FRAME_START() static clock_t frame_start = 0; frame_start = clock()
    #define PROFILE_FRAME_END() do { \
        static int frame_count = 0; \
        static double total_time = 0; \
        clock_t frame_end = clock(); \
        double frame_time = ((double)(frame_end - frame_start)) / CLOCKS_PER_SEC * 1000.0; \
        total_time += frame_time; \
        if (++frame_count % 300 == 0) { \
            printf("[PROFILE] Avg frame time: %.3fms (%.1f FPS)\n", \
                   total_time / frame_count, 1000.0 / (total_time / frame_count)); \
        } \
    } while(0)
#else
    #define PROFILE_START(name)
    #define PROFILE_END(name)
    #define PROFILE_FRAME_START()
    #define PROFILE_FRAME_END()
#endif

#endif // PROFILER_H
```

**Usage in main.c:**
```c
#include "profiler.h"

int main(void) {
    // ... initialization ...
    
    while (!WindowShouldClose()) {
        PROFILE_FRAME_START();
        
        PROFILE_START(update);
        for (int i = 0; i < NUM_BALLS; i++) {
            UpdateBall(&balls[i], SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        PROFILE_END(update);
        
        PROFILE_START(draw);
        BeginDrawing();
        // ... drawing code ...
        EndDrawing();
        PROFILE_END(draw);
        
        PROFILE_FRAME_END();
    }
    
    return 0;
}
```

## 🔧 Custom Build Scripts

### Enhanced Build Scripts

**Create `build-all.sh` for Multiple Configurations:**
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Building all configurations..."

# Build configurations
CONFIGS=("Debug" "Release" "Profile")
TARGETS=("native" "wasm")

for config in "${CONFIGS[@]}"; do
    for target in "${TARGETS[@]}"; do
        echo ""
        echo "Building $target in $config mode..."
        
        if [ "$target" = "native" ]; then
            mkdir -p "build-$target-$config"
            cd "build-$target-$config"
            
            cmake .. -DCMAKE_BUILD_TYPE=$config \
                     -DCMAKE_TOOLCHAIN_FILE=../build/Release/generators/conan_toolchain.cmake
            make -j$(nproc)
            cd ..
        else
            # WebAssembly build
            mkdir -p "build-$target-$config"
            cd "build-$target-$config"
            
            emcmake cmake .. -DCMAKE_BUILD_TYPE=$config -DUSE_CONAN_RAYLIB=OFF
            emmake make -j$(nproc)
            cd ..
        fi
        
        success "$target $config build completed!"
    done
done

echo ""
echo "All builds completed successfully!"
echo ""
echo "Available executables:"
find . -name "raylib-wasm*" -type f | sort
```

### Benchmark Script

**Create `benchmark.sh`:**
```bash
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build-common.sh"

echo "Running performance benchmarks..."

# Build optimized version
./build-native.sh

echo ""
echo "=== Performance Benchmark ==="

# Run with different ball counts
BALL_COUNTS=(1000 2500 5000 7500 10000)

for count in "${BALL_COUNTS[@]}"; do
    echo "Testing with $count balls..."
    
    # Modify NUM_BALLS in source
    sed -i "s/#define NUM_BALLS.*/#define NUM_BALLS $count/" main.c
    
    # Rebuild
    cd build-native && make -j$(nproc) && cd ..
    
    # Run benchmark (timeout after 10 seconds)
    timeout 10s ./build-native/raylib-wasm > /dev/null 2>&1
    
    if [ $? -eq 124 ]; then
        echo "  ✅ $count balls: Stable (ran for 10s)"
    else
        echo "  ❌ $count balls: Crashed or exited early"
    fi
done

# Restore original value
git checkout main.c 2>/dev/null || sed -i "s/#define NUM_BALLS.*/#define NUM_BALLS 2500/" main.c

echo ""
echo "Benchmark complete!"
```

## 🎯 Advanced Configuration Examples

### Multi-Platform CI Configuration

**GitHub Actions with Matrix Builds:**
```yaml
name: Advanced Build Matrix

on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        build_type: [Debug, Release, Profile]
        compiler: [gcc, clang]
        exclude:
          - os: windows-latest
            compiler: gcc
          - os: windows-latest
            compiler: clang
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup
      run: |
        pip install conan
        conan profile detect --force
    
    - name: Build Native
      env:
        CC: ${{ matrix.compiler }}
        CMAKE_BUILD_TYPE: ${{ matrix.build_type }}
      run: |
        ./build-native.sh
    
    - name: Run Tests
      run: |
        cd build-native
        ctest --verbose
    
    - name: Upload Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: ${{ matrix.os }}-${{ matrix.compiler }}-${{ matrix.build_type }}
        path: build-native/raylib-wasm*
```

### Docker Multi-Stage Build

**Advanced Dockerfile:**
```dockerfile
# Multi-stage build for optimization
FROM ubuntu:22.04 AS builder

RUN apt update && apt install -y \
    build-essential \
    cmake \
    python3-pip \
    git \
    ninja-build

RUN pip3 install conan

WORKDIR /app
COPY . .

# Build all configurations
RUN chmod +x *.sh && \
    ./build-all.sh

# Runtime stage
FROM ubuntu:22.04 AS runtime

RUN apt update && apt install -y \
    libgl1-mesa-glx \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/build-native-Release/raylib-wasm ./
COPY --from=builder /app/build-wasm-Release/ ./web/

EXPOSE 8080

CMD ["./raylib-wasm"]
```

## 🎓 Key Takeaways

**Advanced Build System Mastery:**
- ✅ **Custom build types** - Profile, Shipping, Debug variants
- ✅ **Compiler optimizations** - LTO, SIMD, architecture-specific
- ✅ **Quality assurance** - Static analysis, testing, profiling
- ✅ **Performance monitoring** - Tracy, custom profilers, benchmarks

**Professional Development Practices:**
- ✅ **Multi-configuration builds** - Debug, Release, Profile
- ✅ **Automated testing** - Unit tests, memory checks, benchmarks
- ✅ **Continuous integration** - Matrix builds, cross-platform testing
- ✅ **Performance optimization** - Profiling-guided optimization

**Skills Gained:**
- **Build system expertise** - CMake mastery, Conan advanced usage
- **Performance engineering** - Profiling, optimization, benchmarking
- **Quality assurance** - Testing, static analysis, CI/CD
- **Professional workflows** - Multi-stage builds, deployment strategies

---

**Ready to expand the project?** → [Project Expansion](10-project-expansion.md)

**Need troubleshooting help?** → [Troubleshooting Guide](troubleshooting.md)

*Time to read: ~25 minutes | Difficulty: ⭐⭐⭐⭐⭐*