# Building with VS 2015 (v140) Toolset - Solution Guide

## The Problem

When building with the v140 toolset (Visual Studio 2015 compiler), you get this error:

```
c:\program files (x86)\windows kits\10\include\10.0.26100.0\ucrt\wchar.h(316): 
error C3861: '_mm_loadu_si64': identifier not found
```

### Root Cause

The **Windows SDK 10.0.26100.0 is too new** for the VS 2015 compiler. Modern SDKs use intrinsics and features that didn't exist in 2015.

## The Solution

Use **Windows SDK 10.0.22621.0** (or another intermediate version) instead.

### Quick Solution - Manual Steps

1. **Configure with v140 toolset:**
   ```powershell
   cmake -G "Visual Studio 17 2022" -T v140 -A x64 -DCMAKE_CXX_STANDARD=14 -B build-v140-cpp14
   ```

2. **Patch the vcxproj file to use compatible SDK:**
   ```powershell
   (Get-Content "build-v140-cpp14\ResolveSomeErrors\ResolveSomeErrors.vcxproj") `
	   -replace '10.0.26100.0', '10.0.22621.0' | `
	   Set-Content "build-v140-cpp14\ResolveSomeErrors\ResolveSomeErrors.vcxproj"
   ```

3. **Build:**
   ```powershell
   cmake --build build-v140-cpp14
   ```

### Automated Solution - Use the Script

Simply run:

```powershell
.\build-with-v140.ps1
```

This script:
- ✅ Configures CMake with v140 toolset
- ✅ Automatically patches all vcxproj files to use SDK 10.0.22621.0
- ✅ Builds the project
- ✅ Optionally runs the executable

## Available Windows SDKs

Your system has these SDKs installed:

| SDK Version | Compatible with v140? | Status |
|-------------|----------------------|---------|
| 10.0.10240.0 | Should work | ❌ MSBuild can't find it (toolset issue) |
| 10.0.22621.0 | Yes | ✅ **WORKING** |
| 10.0.26100.0 | No | ❌ Too new - missing intrinsics |

## Why CMake Can't Set the SDK Automatically

CMake's `CMAKE_SYSTEM_VERSION` option tells CMake which Windows version to *target*, but:

1. Visual Studio generators **ignore this for SDK selection**
2. CMake uses the **newest available SDK** by default
3. The generated vcxproj files hardcode the SDK version
4. There's no direct CMake option to force an older SDK with newer VS

## Alternative: Install Visual Studio 2015 Standalone

For true VS 2015 compatibility testing, install:

1. **Visual Studio 2015 Community** (standalone installation)
2. This includes a compatible Windows SDK (8.1 or 10.0.10240.0)
3. Set environment to VS 2015 before running CMake:
   ```powershell
   & "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x64
   cmake -G "Visual Studio 14 2015" -A x64 -B build-vs2015
   cmake --build build-vs2015
   ```

## Limitations

Even with the v140 toolset and SDK 10.0.22621.0:

- ⚠️ **C++20 features** still enforce strict standards (even on v140)
- ⚠️ **Removed C++17 features** (like `std::auto_ptr`) still don't exist
- ⚠️ This tests the **compiler version**, not the full IDE experience

To truly test "old code that worked on VS 2015", you need:
- VS 2015 compiler (v140) ✅ You have this
- C++14 or earlier standard ✅ The script sets this
- Compatible Windows SDK ✅ 10.0.22621.0 works
- Old code patterns (see `ResolveSomeErrors.cpp`) ✅ Documented

## Testing the Examples

The current code in `ResolveSomeErrors.cpp` uses **modern C++17/20 patterns** that work on both old and new compilers.

To test code that would **fail on modern MSVC but work on VS 2015**, you would need to:

1. Set C++ standard to C++14
2. Uncomment the old code patterns (like `std::auto_ptr`)
3. Build with the v140 toolset

However, even then, **many features were already deprecated in C++14**, so they would generate warnings.

## Conclusion

✅ **You can now build with the v140 toolset** using the provided script

✅ **SDK 10.0.22621.0 is the compatibility sweet spot**

❌ **But this still won't let old non-conforming code compile** because:
- Removed C++17 features are gone from the standard library
- The SDK is still newer than what shipped with VS 2015
- C++20 standard enforces strict rules

For true "this worked on VS 2015 but fails now" testing, you need a full VS 2015 installation with its original SDK.
