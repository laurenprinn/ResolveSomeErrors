# VS 2015 vs Modern MSVC Compatibility

This document explains what code patterns in `ResolveSomeErrors.cpp` would **compile successfully on VS 2015** but **fail on modern MSVC**.

## Summary

The code now in `ResolveSomeErrors.cpp` has been updated to **build successfully on modern MSVC** by using the modern replacements. The commented-out sections show what VS 2015 code would have looked like.

## Features That Would Work on VS 2015 but Fail on Modern MSVC (C++17/20)

### 1. **std::auto_ptr** (Removed in C++17)
**VS 2015 with C++14:**
```cpp
std::auto_ptr<int> ptr(new int(42)); // ✓ Compiles (deprecated warning)
```

**Modern MSVC with C++17+:**
```
error C2039: 'auto_ptr': is not a member of 'std'
```

### 2. **std::iterator Base Class** (Removed in C++17)
**VS 2015:**
```cpp
template<typename T>
class MyIterator : public std::iterator<std::forward_iterator_tag, T> {
	// This was the recommended way
};
```

**Modern MSVC C++17+:**
```
error C2039: 'iterator': is not a member of 'std'
```

### 3. **std::bind1st / std::bind2nd** (Removed in C++17)
**VS 2015:**
```cpp
auto add5 = std::bind1st(std::plus<int>(), 5); // ✓ Works
```

**Modern MSVC C++17+:**
```
error C2039: 'bind1st': is not a member of 'std'
```

### 4. **std::unary_function / std::binary_function** (Removed in C++17)
**VS 2015:**
```cpp
struct MyFunc : public std::unary_function<int, int> {
	int operator()(int x) const { return x * 2; }
};
```

**Modern MSVC C++17+:**
```
error C2039: 'unary_function': is not a member of 'std'
```

### 5. **std::random_shuffle** (Removed in C++17)
**VS 2015:**
```cpp
std::random_shuffle(v.begin(), v.end()); // ✓ Works
```

**Modern MSVC C++17+:**
```
error C3861: 'random_shuffle': identifier not found
```

### 6. **std::mem_fun / std::ptr_fun** (Removed in C++17)
**VS 2015:**
```cpp
auto f = std::mem_fun(&std::string::size); // ✓ Works
```

**Modern MSVC C++17+:**
```
error C2039: 'mem_fun': is not a member of 'std'
```

### 7. **throw() Exception Specification** (Deprecated in C++17)
**VS 2015:**
```cpp
void foo() throw() { } // ✓ Standard practice
```

**Modern MSVC C++17+:**
```
warning C5040: dynamic exception specifications are valid only in C++14 and earlier
```

### 8. **Trigraphs** (Removed in C++17)
**VS 2015:**
```cpp
const char* s = "What??!"; // ??! converts to |, becomes "What|"
```

**Modern MSVC C++17+:**
```cpp
const char* s = "What??!"; // No trigraph processing, stays as "What??!"
```

### 9. **Friend Name Injection with /permissive-**
**VS 2015 (permissive mode):**
```cpp
template<typename T>
class Container {
	friend void process(const Container& c) { }
};

void use() {
	Container<int> c;
	process(c); // ✓ Found via ADL
}
```

**Modern MSVC with /permissive-:**
```
error C3861: 'process': identifier not found
```

### 10. **Missing Header Transitive Includes**
**VS 2015:**
```cpp
#include <iostream>
// std::sort available without #include <algorithm> (transitive)
```

**Modern MSVC:**
```
error C3861: 'sort': identifier not found
// Must explicitly: #include <algorithm>
```

## Why Can't We Test with v140 Toolset?

When we tried building with the v140 (VS 2015) toolset, we encountered:

1. **Windows SDK Incompatibility**: The modern Windows SDK 10.0.26100.0 uses intrinsics and features not available in the VS 2015 compiler
2. **Even with v140, the C++20 standard** enforces stricter rules

To truly test with VS 2015 behavior, you would need:
- A standalone VS 2015 installation
- An older Windows SDK (10.0.10240 or 10.0.14393)
- Set the C++ standard to C++14 or earlier

## Modern Replacements (Now in Code)

All the examples in `ResolveSomeErrors.cpp` now use the modern, correct approach:

| Old (VS 2015) | Modern (C++17/20) |
|---------------|-------------------|
| `std::auto_ptr<T>` | `std::unique_ptr<T>` or `std::shared_ptr<T>` |
| `std::iterator<...>` base | Define traits manually |
| `std::bind1st/2nd` | Lambdas or `std::bind` |
| `std::unary_function` | No base class needed |
| `std::random_shuffle` | `std::shuffle` with URBG |
| `std::mem_fun` | `std::mem_fn` or lambdas |
| `throw()` | `noexcept` |
| Trigraphs | Literal characters |
| Friend injection | Explicit forward declarations |
| Transitive includes | Explicit `#include` directives |

## Conclusion

The  code in `ResolveSomeErrors.cpp` now **successfully builds on modern MSVC** using C++20 standards. The commented sections show what VS 2015 code would have looked like. To see actual compilation failures, uncomment the old code patterns.
