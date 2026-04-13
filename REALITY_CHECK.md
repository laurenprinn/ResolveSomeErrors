# Code That Builds on Older MSVC But Fails on Modern MSVC

## Current Status

The code in `ResolveSomeErrors.cpp` demonstrates **non-conforming C++ code patterns** that:

✅ **FAIL on modern MSVC** (VS 2022/2026 with C++20)  
❌ **ALSO FAIL on old MSVC** (VS 2015 with C++14)

## Why This Happens

The reality is that **most non-conforming code patterns fail on both old and new compilers** because:

1. **C++ Standards have always required typename** - Even C++98 required `typename` for dependent types
2. **C++14 was already strict** - By VS 2015, most conformance issues were warnings or errors
3. **Removed features (C++17)** - Features like `std::auto_ptr` were already deprecated in C++11, and removed entirely in C++17

## What Actually Changed

The main evolution from VS 2015 to modern MSVC:

| Feature | VS 2015 (v140) | Modern MSVC (v143) |
|---------|----------------|-------------------|
| `/permissive-` mode | Not available | **Default in new projects** |
| `std::auto_ptr` | Deprecated (warning) | Removed (error) |
| `std::random_shuffle` | Deprecated (warning) | Removed (error) |
| `std::bind1st/2nd` | Deprecated (warning) | Removed (error) |
| `std::iterator` base | Deprecated (warning) | Removed (error) |
| Two-phase lookup | Relaxed | **Strict** |
| Narrowing conversions | Warning | Warning or error |

## Real World Scenario

**Code that truly builds on VS 2015 but fails on modern MSVC must:**
1. Use C++14 or earlier standard
2. Use features deprecated in C++14/17
3. Accept deprecation warnings

**Example:**
```cpp
// This compiles on VS 2015 with C++14 (with warnings)
// This FAILS on VS 2022 with C++17+
#include <memory>

void oldCode() {
	std::auto_ptr<int> ptr(new int(42));  // Deprecated in C++11, removed in C++17
}
```

## The Problem We Encountered

When we tried to use removed C++17 features:
- They don't exist in `<memory>`, `<functional>`, `<algorithm>` headers
- Even VS 2015 can't find them with C++14
- They were already gone by the time VS 2015 shipped

## What We Actually Demonstrated

The current `ResolveSomeErrors.cpp` shows:

1. ✅ **Missing `typename`** - Causes errors in both old and modern MSVC  
2. ✅ **Unqualified dependent names** - Causes errors in both old and modern MSVC  
3. ✅ **Narrowing conversions** - Warnings in both, error if `/WX` is set  
4. ✅ **Missing `typename` for iterators** - Causes errors in both old and modern MSVC

**These are C++ standard violations that have ALWAYS been wrong** - modern compilers are just better at catching them.

## Conclusion

### What We Learned

It's **very difficult** to find code that:
- Builds successfully on VS 2015
- Fails on modern MSVC
- Isn't just using removed C++17 features

### Why?

Because **VS 2015 was already quite conformant**! Even in 2015:
- `typename` was required for dependent types
- Two-phase lookup was partially enforced  
- Most bad practices generated warnings

### The Real Difference

The **main** reason old code fails on modern MSVC:

1. **`/permissive-` is now default** - Stricter standards conformance
2. **C++17/20 features were removed** - `std::auto_ptr`, `std::random_shuffle`, etc.
3. **Better diagnostics** - Modern compilers catch more edge cases
4. **SDK incompatibilities** - Newer Windows SDKs don't work with old compilers

## Recommendations

If you're migrating code from VS 2015 to modern MSVC:

1. **Start with C++14** - Match the old standard first
2. **Fix conformance issues** - Add `typename`, qualify dependent names
3. **Replace removed features** - `auto_ptr` → `unique_ptr`, etc.
4. **Update to C++17/20** - Once code builds with C++14
5. **Enable `/permissive-`** - For strict conformance

Files in this project:
- ✅ **build-with-v140.ps1** - Builds with VS 2015 compiler
- ✅ **build-with-v141.ps1** - Builds with VS 2017 compiler
- ✅ **build-with-toolset.ps1** - Generic build script
- ✅ **compare-toolsets.ps1** - Compare builds across versions

Use these scripts to test your code across different compiler versions!
