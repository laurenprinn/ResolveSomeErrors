# Quick Reference - Build Scripts

## One-Line Commands

### Build with Specific Toolset

```powershell
# VS 2015 (v140)
.\build-with-v140.ps1

# VS 2017 (v141)  
.\build-with-v141.ps1

# VS 2019 (v142)
.\build-with-toolset.ps1 -Toolset v142

# VS 2022 (v143)
.\build-with-toolset.ps1 -Toolset v143
```

### Build with Different C++ Standards

```powershell
# C++11
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 11

# C++14 (default)
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 14

# C++17
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 17

# C++20
.\build-with-toolset.ps1 -Toolset v143 -CppStandard 20
```

### Build All Toolsets and Compare

```powershell
# Build with all available toolsets
.\compare-toolsets.ps1

# With specific standard
.\compare-toolsets.ps1 -CppStandard 17

# Release build
.\compare-toolsets.ps1 -BuildType Release
```

## Common Scenarios

### Test Code Compatibility Across Compiler Versions

```powershell
# Test if code builds on VS 2015
.\build-with-v140.ps1

# Test if code builds on VS 2017  
.\build-with-v141.ps1

# Compare all versions
.\compare-toolsets.ps1
```

### Test C++ Standard Features

```powershell
# Test C++17 features with different compilers
.\build-with-toolset.ps1 -Toolset v141 -CppStandard 17  # VS 2017
.\build-with-toolset.ps1 -Toolset v142 -CppStandard 17  # VS 2019
.\build-with-toolset.ps1 -Toolset v143 -CppStandard 17  # VS 2022
```

### Reproduce Build Issues

```powershell
# If code fails on v140, reproduce it:
.\build-with-v140.ps1

# Then compare with working version:
.\build-with-v143.ps1
```

## Toolset Matrix

| Toolset | Compiler | Recommended SDK | C++11 | C++14 | C++17 | C++20 |
|---------|----------|-----------------|-------|-------|-------|-------|
| v140 | MSVC 19.0 | 10.0.22621.0 | ✅ | ✅ | ⚠️ | ❌ |
| v141 | MSVC 19.1x | 10.0.22621.0 | ✅ | ✅ | ✅ | ⚠️ |
| v142 | MSVC 19.2x | 10.0.26100.0 | ✅ | ✅ | ✅ | ✅ |
| v143 | MSVC 19.3x+ | 10.0.26100.0 | ✅ | ✅ | ✅ | ✅ |

Legend:
- ✅ Full support
- ⚠️ Partial support
- ❌ Not supported

## Troubleshooting

### "Toolset not found"
Install the required Visual Studio version or use a different toolset.

### "SDK version not found"
Specify a different SDK:
```powershell
.\build-with-toolset.ps1 -Toolset v140 -SdkVersion "10.0.22621.0"
```

### "Build failed"
Check the error messages. Common issues:
- Missing C++ standard features → Use newer toolset
- Removed C++17 features (std::auto_ptr) → Update code or use C++14

### Script won't run
Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Files Overview

| File | Purpose |
|------|---------|
| `build-with-v140.ps1` | Build with VS 2015 |
| `build-with-v141.ps1` | Build with VS 2017 |
| `build-with-toolset.ps1` | Generic script for any toolset |
| `compare-toolsets.ps1` | Build and compare all toolsets |
| `BUILD_SCRIPTS_README.md` | Full documentation |
| `Building_with_v140_Solution.md` | SDK compatibility details |
| `VS2015_Compatibility_Notes.md` | C++ standard changes |

## See Also

- **Full Documentation**: `BUILD_SCRIPTS_README.md`
- **SDK Issues**: `Building_with_v140_Solution.md`
- **C++ Compatibility**: `VS2015_Compatibility_Notes.md`
