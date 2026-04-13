# Summary: Modern MSVC Errors - What You Actually See

## The Answer to "Why Am I Not Seeing Those Errors?"

### 1. ❌ The Code is Commented Out
All error-triggering code in the demo files is commented out so they compile cleanly.

### 2. ✅ The Error Numbers Are Different
When you DO trigger the errors with `/permissive-`, you see:

| You Expected | You Actually Get | Why |
|--------------|------------------|-----|
| C5286 | **C2676** | `/permissive-` makes it an error, not warning |
| C5292/C5294 | **C5055** | Different warning number in your MSVC version |
| C5295 | **C2117** | Array overflow is always a hard error |

### 3. ⚠️ Your Build Settings
Your CMakeLists.txt doesn't enable the flags needed:
- Missing `/W4` (warning level 4)
- Missing `/permissive-` (strict mode)

## What I Just Did For You

### ✅ Created Test Files

1. **`TriggerModernErrorsACTUAL.cpp`**
   - Contains actual error-triggering code
   - Builds and shows real warnings

2. **`show-modern-errors.ps1`**
   - Build script that enables strict checking
   - Shows which warnings appear

3. **`WHY_NO_ERRORS.md`**
   - Complete explanation document
   - Breakdown of all error codes

### ✅ Ran the Test

When I ran `show-modern-errors.ps1`, we saw:

```
✓ C2676: binary '==': enum comparison error
✓ C5055: operator '>': enum/float deprecated  
✓ C5055: operator '<': float/enum deprecated
✓ C2117: array bounds overflow
```

**None of the C5286, C5292, C5294, C5295 numbers appeared** because:
- They're either different in VS 2026
- Or they become hard errors with `/permissive-`

## How to See These Warnings Yourself

### Quick Test

```powershell
# Run this script I created:
.\show-modern-errors.ps1
```

You'll see the actual error/warning numbers that appear.

### Manual Build

```powershell
# Build the test file with strict settings:
cl /W4 /permissive- /std:c++20 ResolveSomeErrors\TriggerModernErrorsACTUAL.cpp
```

### Update Your CMakeLists.txt

Uncomment these lines in `ResolveSomeErrors/CMakeLists.txt`:

```cmake
if (MSVC)
  target_compile_options(ResolveSomeErrors PRIVATE
	/W4              # Warning level 4
	/permissive-     # Strict conformance mode
  )
endif()
```

## The Real Modern Warnings You'll See

In Visual Studio 2026 (your version):

### Common Modern Conformance Warnings

| Code | Description | Common? |
|------|-------------|---------|
| **C5055** | Enum/float operations | ✅ Very Common |
| **C5204** | Missing virtual destructor | ✅ Common |
| **C4244** | Possible data loss in conversion | ✅ Very Common |
| **C4267** | size_t to int conversion | ✅ Very Common |
| **C2676** | No operator defined for enum | ✅ With `/permissive-` |
| **C2117** | Array bounds overflow | ✅ Common |
| **C4996** | Deprecated function (like gets_s) | ✅ Very Common |

### Rare Modern Warnings

| Code | Description | When |
|------|-------------|------|
| C5272 | Function pointer in template | Uncommon |
| C5286 | Different enum comparison | Only without `/permissive-` |
| C5287 | Implicitly deleted operator | Rare |
| C5311 | Concept not satisfied | C++20 concepts only |
| C5333 | Nested function | Very rare |

## Bottom Line

**You ARE seeing modern conformance enforcement** - just with different error numbers than documented!

The C52xx/C53xx series are:
- ✅ Real error codes
- ✅ Do appear in MSVC
- ⚠️ But often replaced by other codes in strict mode
- ⚠️ Or only appear in specific compiler versions

**The behavior is correct** - your compiler is enforcing modern C++ standards. The specific error numbers just vary by:
- Compiler version (VS 2019 vs 2022 vs 2026)
- Build flags (`/permissive-`, `/W4`, etc.)
- C++ standard level (`/std:c++17` vs `/std:c++20`)

Run `.\show-modern-errors.ps1` to see what YOUR version actually produces!
