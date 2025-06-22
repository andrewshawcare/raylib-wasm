# ⚡ Quick Start Guide

**Goal:** Get 2,500 bouncing balls running in 5 minutes! 🏀

Perfect for developers who want to see immediate results. We'll get you up and running with both desktop and web versions of the demo.

## 🎯 What You'll Have Running

A high-performance animation with thousands of colorful balls bouncing around your screen at 60fps - running both as a native desktop application AND in your web browser!

## 📋 Prerequisites Check

Quickly verify you have the essentials:

```bash
# Check if you have the required tools
conan --version    # Should show Conan 2.x
cmake --version    # Should show CMake 3.15+
gcc --version      # Or clang - any modern C compiler
```

❌ **Missing tools?** Don't worry! The build scripts will guide you through installation.

## 🚀 Lightning Fast Setup

### Step 1: Build Desktop Version (2 minutes)

```bash
./build-native.sh
```

**What's happening?** This script:
- Downloads raylib using Conan package manager
- Configures the build with CMake
- Compiles your C code into a native executable
- Automatically runs the application

🎉 **Success!** You should see a window with thousands of bouncing balls!

### Step 2: Build Web Version (3 minutes)

```bash
./build-wasm.sh
```

**What's happening?** This script:
- Downloads Emscripten (WebAssembly compiler)
- Compiles your C code to WebAssembly
- Creates HTML, JS, and WASM files
- Provides instructions for viewing in browser

🌐 **View in browser:**
```bash
cd build-wasm
python3 -m http.server 8080
# Open http://localhost:8080/raylib-wasm.html
```

## 🎮 Try It Out!

**Desktop version:**
- Watch the performance counter
- Try resizing the window
- Press `Ctrl+C` to exit

**Web version:**
- Same smooth animation in your browser
- Works on mobile devices too!
- Press F12 to see developer tools

## 🧪 Quick Experiments

**Want to see immediate changes?** Try these 30-second modifications:

### Experiment 1: Change Ball Count
```c
// In main.c, line 8:
#define NUM_BALLS 5000  // Was 2500 - double the chaos!
```

### Experiment 2: Bigger Balls
```c
// In main.c, line 9:
#define BALL_RADIUS 30.0f  // Was 20.0f - chunkier balls!
```

### Experiment 3: Faster Balls
```c
// In main.c, line 11:
#define BALL_MAX_SPEED 15.0f  // Was 8.0f - need for speed!
```

**Rebuild and see changes:**
```bash
./build-native.sh  # Rebuild desktop version
```

## 🔄 Pro Tip: Auto-Rebuild

Want changes to appear instantly as you code?

```bash
./watch.sh
```

This starts a file watcher that automatically rebuilds and runs your project whenever you save `main.c`!

## ✅ Success Checklist

You've completed the quick start if you:

- ✅ Built the desktop version successfully
- ✅ Built the web version successfully  
- ✅ Saw 2,500+ balls bouncing smoothly
- ✅ Made at least one code modification
- ✅ Understand the basic workflow

## 🎓 What's Next?

**Impressed with the setup?** Dive deeper:

- **Curious about the code?** → [Understanding the Code](03-understanding-the-code.md)
- **Want to understand the build system?** → [Build System Fundamentals](04-build-system-fundamentals.md)
- **Ready for more advanced topics?** → [Project Overview](02-project-overview.md)

**Having issues?** → [Troubleshooting Guide](troubleshooting.md)

## 🤔 What Just Happened?

In just 5 minutes, you experienced:

🏗️ **Modern C Build System** - CMake + Conan package management  
🎯 **Cross-Platform Compilation** - Same code, multiple targets  
⚡ **High Performance Graphics** - 60fps with thousands of objects  
🌐 **WebAssembly Magic** - C code running in browsers  
🔄 **Professional Workflow** - Automated building and testing  

**This isn't your grandfather's C programming!** You just used cutting-edge tools that professional game developers and systems programmers use daily.

---

**Ready to dive deeper?** The real learning begins in the next section! 🚀

*Time spent: ~5 minutes | Difficulty: ⭐☆☆☆☆*