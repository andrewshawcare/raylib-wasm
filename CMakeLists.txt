cmake_minimum_required(VERSION 3.15)
project(raylib-wasm C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Compiler-specific options for better code quality
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DNDEBUG")
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W4")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /O2 /DNDEBUG")
endif()

# Choose raylib source based on build target
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    # For WebAssembly, use FetchContent to build raylib from source
    set(OPENGL_VERSION "ES 2.0" CACHE STRING "OpenGL Version" FORCE)
    
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
else()
    # For native builds, use Conan-provided raylib
    find_package(raylib REQUIRED)
endif()

add_executable(${PROJECT_NAME} main.c)
target_link_libraries(${PROJECT_NAME} raylib)

# Configure for WebAssembly if using Emscripten
if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    # WebAssembly-specific compiler flags
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_GLFW=3")
    
    # Optimization and linking flags for WebAssembly
    set(EMSCRIPTEN_LINK_FLAGS "-s USE_GLFW=3 -s ASSERTIONS=1 -s WASM=1 -s ASYNCIFY -s GL_ENABLE_GET_PROC_ADDRESS=1")
    
    # Add optimization flags based on build type
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