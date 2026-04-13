# Build Scripts for Different MSVC Toolsets

This directory contains helper scripts to build the project with different MSVC compiler versions (toolsets).

## Available Toolsets

| Toolset | Version | Year | Script |
|---------|---------|------|--------|
| v140 | MSVC 19.0 | Visual Studio 2015 | `build-with-v140.ps1` |
| v141 | MSVC 19.1x | Visual Studio 2017 | `build-with-v141.ps1` |
| v142 | MSVC 19.2x | Visual Studio 2019 | Generic script only |
| v143 | MSVC 19.3x | Visual Studio 2022 | Generic script only |

## Quick Start

### Option 1: Use Specific Toolset Scripts

Build with **VS 2015 (v140)**:
```powershell
.\build-with-v140.ps1
```

Build with **VS 2017 (v141)**:
```powershell
.\build-with-v141.ps1
```

### Option 2: Use Generic Script

The generic script supports all toolsets with more options:

```powershell
# VS 2015
.\build-with-toolset.ps1 -Toolset v140

# VS 2017
.\build-with-toolset.ps1 -Toolset v141

# VS 2019
.\build-with-toolset.ps1 -Toolset v142

# VS 2022
.\build-with-toolset.ps1 -Toolset v143
```

### Advanced Usage

**Specify C++ Standard:**
```powershell
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 17
```

**Specify Build Type:**
```powershell
.\build-with-toolset.ps1 -Toolset v140 -BuildType Release
```

**Specify SDK Version:**
```powershell
.\build-with-toolset.ps1 -Toolset v141 -SdkVersion "10.0.26100.0"
```

**Combine Multiple Options:**
```powershell
.\build-with-toolset.ps1 -Toolset v140 -CppStandard 14 -BuildType Release -SdkVersion "10.0.22621.0"
```

## Parameters

### build-with-v140.ps1 and build-with-v141.ps1

- **BuildType** (optional): `Debug` or `Release` (default: `Debug`)
- **SdkVersion** (optional): Windows SDK version (default: `10.0.22621.0`)

Example:
```powershell
.\build-with-v140.ps1 -BuildType Release -SdkVersion "10.0.22621.0"
```

### build-with-toolset.ps1

- **Toolset** (required): `v140`, `v141`, `v142`, or `v143`
- **BuildType** (optional): `Debug` or `Release` (default: `Debug`)
- **CppStandard** (optional): `11`, `14`, `17`, or `20` (default: `14`)
- **SdkVersion** (optional): Windows SDK version (auto-selected by default)

## Windows SDK Compatibility

Your system has these SDKs installed:

| SDK Version | v140 (2015) | v141 (2017) | v142 (2019) | v143 (2022) |
|-------------|-------------|-------------|-------------|-------------|
| 10.0.10240.0 | ⚠️ Limited | ✅ Yes | ✅ Yes | ✅ Yes |
| 10.0.22621.0 | ✅ **Recommended** | ✅ **Recommended** | ✅ Yes | ✅ Yes |
| 10.0.26100.0 | ❌ Too new | ⚠️ May work | ✅ **Recommended** | ✅ **Recommended** |

**Default SDK Selection:**
- v140: Uses 10.0.22621.0 (latest compatible SDK)
- v141: Uses 10.0.22621.0 (safe middle ground)
- v142: Uses 10.0.26100.0 (latest)
- v143: Uses 10.0.26100.0 (latest)

## Why Use These Scripts?

### The Problem

When building with older toolsets (like v140), CMake automatically selects the **newest Windows SDK** installed on your system. Older compilers can't handle modern SDK features:

```
error C3861: '_mm_loadu_si64': identifier not found
```

### The Solution

These scripts:
1. ✅ Configure CMake with the specified toolset
2. ✅ Automatically patch generated project files to use a compatible SDK
3. ✅ Build the project successfully
4. ✅ Optionally run the executable

## Testing Toolset Availability

Check which toolsets are installed:

```powershell
Get-ChildItem "C:\Program Files*\Microsoft Visual Studio\*\*\VC\Tools\MSVC\" -ErrorAction SilentlyContinue | Get-ChildItem | Select-Object Name
```

Look for version numbers:
- **14.0x** → v140 (VS 2015)
- **14.1x** → v141 (VS 2017)
- **14.2x** → v142 (VS 2019)
- **14.3x** → v143 (VS 2022)
- **14.4x+** → v143+ (VS 2022 updates)

## Examples

### Compare Builds Across Toolsets

```powershell
# Build with VS 2015
.\build-with-toolset.ps1 -Toolset v140 -CppStandard 14

# Build with VS 2017
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 17

# Build with VS 2022
.\build-with-toolset.ps1 -Toolset v143 -CppStandard 20
```

### Test C++ Standard Evolution

```powershell
# C++11 with VS 2017
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 11

# C++14 with VS 2017
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 14

# C++17 with VS 2017
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 17
```

## Troubleshooting

### Build Fails with "SDK not found"

Try using a different SDK version:
```powershell
.\build-with-toolset.ps1 -Toolset v140 -SdkVersion "10.0.22621.0"
```

### Build Fails with "Toolset not found"

The toolset isn't installed. Install the required Visual Studio version or use a different toolset.

### Build Succeeds but Runtime Errors

Ensure you're running the correct executable:
```
build-<toolset>-cpp<standard>\ResolveSomeErrors\<Debug|Release>\ResolveSomeErrors.exe
```

### C++ Standard Features Missing

Some features are only available in certain standards:
- **C++11**: auto, lambda, nullptr, range-for
- **C++14**: generic lambdas, binary literals
- **C++17**: structured bindings, if constexpr, std::optional
- **C++20**: concepts, ranges, coroutines, modules

Also, some features were **removed**:
- **C++17**: std::auto_ptr, std::random_shuffle, std::iterator
- See `VS2015_Compatibility_Notes.md` for details

## Files

- **`build-with-v140.ps1`** - VS 2015 specific build script
- **`build-with-v141.ps1`** - VS 2017 specific build script
- **`build-with-toolset.ps1`** - Generic script for all toolsets
- **`Building_with_v140_Solution.md`** - Detailed v140 SDK solution guide
- **`VS2015_Compatibility_Notes.md`** - C++17/20 compatibility notes

## Learn More

- [Microsoft C++ Documentation](https://docs.microsoft.com/cpp/)
- [Visual Studio Platform Toolsets](https://docs.microsoft.com/visualstudio/releases/)
- [C++ Standards Support](https://docs.microsoft.com/cpp/overview/visual-cpp-language-conformance)
