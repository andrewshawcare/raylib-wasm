# Raylib Bouncing Ball

A simple bouncing ball demo using the Raylib graphics library, written in C. This project demonstrates cross-platform compilation for both native execution and WebAssembly deployment in browsers.

## Features

- **Bouncing ball physics simulation** - Real-time physics with wall collision detection
- **Cross-platform builds** - Single codebase compiles to native executable and WebAssembly
- **Development workflow** - Automated file watching and rebuilding for rapid development
- **Clean build system** - Conan-based dependency management with CMake integration

## Prerequisites

### For all builds:
- Python 3 with pip
- CMake
- C compiler (GCC, Clang, or MSVC)
- Conan package manager

#### Installing Conan:
```bash
pip install conan
```

That's it! Conan will automatically manage dependencies including:
- Raylib library (for native builds)
- Emscripten SDK (for WebAssembly builds)

Note: For WebAssembly builds, raylib is built from source using FetchContent to ensure proper WebAssembly compatibility.

## Building

### WebAssembly (Browser)

```bash
chmod +x build-wasm.sh
./build-wasm.sh
```

This will:
1. Install Emscripten SDK via Conan (raylib built from source)
2. Configure and build the WebAssembly version  
3. Generate `raylib-wasm.html`, `raylib-wasm.js`, and `raylib-wasm.wasm`

To test:
```bash
cd build-wasm
python3 -m http.server 8080
# Open http://localhost:8080/raylib-wasm.html in your browser
```

### Native Executable

```bash
chmod +x build-native.sh
./build-native.sh
```

This will:
1. Install dependencies (Raylib) via Conan
2. Configure and build the native executable
3. Optionally run the application

## Development Workflow

### File Watching (Auto-rebuild)

```bash
chmod +x watch.sh
./watch.sh
```

This will:
1. Install `inotify-tools` if needed for file watching
2. Run initial builds for both WebAssembly and native versions
3. Watch `main.c` for changes and automatically rebuild both versions
4. Clean up all build artifacts when you stop watching (Ctrl+C)

Perfect for development - just save your file and both versions rebuild automatically!

The watch script automatically runs the native application and starts a web server for the WebAssembly version for immediate testing.

### Manual Cleanup

```bash
chmod +x cleanup.sh
./cleanup.sh
```

This will remove:
- All build directories (`build-wasm/`, `build-native/`, `build/`)
- Conan-generated artifacts
- CMake cache files and generated artifacts
- Running processes (web servers, native applications)

## Build System Architecture

This project uses a hybrid build system combining **Conan** for dependency management and **CMake** for build configuration:

### Native Builds
- **Dependencies**: Raylib library via Conan package manager
- **Toolchain**: System's default C compiler (GCC/Clang/MSVC)
- **Output**: Native executable optimized for the host platform

### WebAssembly Builds
- **Dependencies**: Emscripten SDK via Conan, Raylib built from source via CMake FetchContent
- **Toolchain**: Emscripten compiler toolchain (emcc/em++)
- **Output**: HTML + JavaScript + WebAssembly files for browser deployment

### Why This Approach?
- **Raylib Native**: Uses pre-built Conan package for faster builds and platform optimization
- **Raylib WebAssembly**: Built from source to ensure proper WebAssembly compatibility and optimization
- **Single CMakeLists.txt**: Detects build type and configures dependencies accordingly

## Environment Variables

You can control build script behavior with environment variables:

### AUTO_RUN
Controls whether the native application runs automatically after building:
```bash
AUTO_RUN=1 ./build-native.sh  # Runs the app automatically
./build-native.sh             # Asks for user input (default)
```

### AUTO_SERVE
Controls whether a web server starts automatically for WebAssembly builds:
```bash
AUTO_SERVE=1 ./build-wasm.sh        # Starts web server automatically
AUTO_SERVE=1 SERVE_PORT=3000 ./build-wasm.sh  # Custom port
./build-wasm.sh                      # Shows manual instructions (default)
```

The watch script automatically sets `AUTO_RUN=1` and `AUTO_SERVE=1` for seamless testing.

## Project Structure

```
raylib-wasm/
├── main.c              # Source code
├── CMakeLists.txt      # Build configuration (hybrid Conan/FetchContent)
├── conanfile.txt       # Conan dependencies (native builds)
├── conanfile-wasm.txt  # Conan dependencies (WebAssembly builds)
├── build-wasm.sh       # WebAssembly build script
├── build-native.sh     # Native build script
├── watch.sh            # File watcher script (auto-rebuild)
├── cleanup.sh          # Cleanup script (remove build artifacts)
├── README.md           # This file
└── .gitignore          # Git ignore rules
```

## Troubleshooting

### Common Issues

**Conan not found**
```bash
pip install conan
```

**Emscripten tools not available after Conan installation**
- The build script will automatically fall back to downloading emsdk directly
- Ensure you have `git` installed for the fallback method

**inotify-tools missing (Linux only)**
- The watch script will attempt automatic installation
- Manual installation: `sudo apt install inotify-tools` (Ubuntu/Debian)

**Build fails with CMake errors**
- Try cleaning the project: `./cleanup.sh`
- Ensure CMake version is 3.15 or higher

**WebAssembly build works but native build fails**
- Check that your system has a C compiler installed
- Verify Conan can detect your default profile: `conan profile detect`

### Performance Tips

**Native Builds**
- Use Release build type for better performance (already set in scripts)
- The executable is optimized for your specific platform

**WebAssembly Builds**
- Builds include optimizations for size and performance
- Modern browsers provide good WebAssembly performance

## Development Best Practices

### Code Structure
- Keep game logic in separate functions for better organization
- Use const for immutable values (screen dimensions, etc.)
- Follow consistent naming conventions

### Build Workflow
1. Use `./watch.sh` during active development
2. Test both native and WebAssembly versions regularly
3. Run `./cleanup.sh` if you encounter build issues
4. Use environment variables to control build behavior in CI/CD

### Version Control
- The `.gitignore` file excludes all build artifacts
- Only source files and build scripts are tracked
- Clean builds ensure reproducible results

## Controls

- Close the window or press ESC to exit

## License

This project is provided as-is for educational purposes.