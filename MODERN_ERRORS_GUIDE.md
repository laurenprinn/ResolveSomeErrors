# Modern MSVC Conformance Errors (C52xx and C53xx Series)

These errors appear in **Visual Studio 2019+** with stricter C++ conformance checking, especially with `/permissive-` mode and C++20 standard.

## Quick Reference

| Error | Category | Standard | Severity |
|-------|----------|----------|----------|
| C5272 | Template Arguments | C++17/20 | Error |
| C5286 | Enum Comparison | C++20 | Warning (Error with `/we5286`) |
| C5287 | Implicitly Deleted | C++11/14 | Warning |
| C5292 | Enum/Float Ops | C++20 | Warning (Error with `/we5292`) |
| C5294 | Float/Enum Ops | C++20 | Warning (Error with `/we5294`) |
| C5295 | Array Bounds | All | Warning |
| C5311 | Concepts | C++20 | Error |
| C5333 | Nested Functions | All | Error |

---

## C5272: Invalid Function Pointer in Constant Expression

### What Triggers It
Using a function pointer directly as a template argument without the address-of operator.

### Example
```cpp
void foo() {}

template<auto F>
struct Wrapper {};

Wrapper<foo> w;  // ❌ C5272
```

### How to Fix
```cpp
// Option 1: Use address-of operator
Wrapper<&foo> w;  // ✅

// Option 2: Use function object / lambda
auto lambda = []() { foo(); };
Wrapper<lambda> w2;  // ✅

// Option 3: Use different template parameter type
template<void(*F)()>
struct BetterWrapper {};

BetterWrapper<&foo> w3;  // ✅
```

### When It Appears
- VS 2019 16.8+
- With `/std:c++17` or later
- Template metaprogramming with function pointers

---

## C5286: Deprecated Comparison Between Different Enums

### What Triggers It
Comparing values from different enumeration types (deprecated in C++20).

### Example
```cpp
enum class Color { Red, Blue };
enum class Size { Small, Large };

if (Color::Red == Size::Small) {}  // ❌ C5286
```

### How to Fix
```cpp
// Option 1: Cast to common underlying type
if (static_cast<int>(Color::Red) == static_cast<int>(Size::Small)) {}  // ✅

// Option 2: Redesign to use same enum or separate comparisons
// Option 3: Use different types entirely (not enums)

// Option 4: Treat as error to catch bugs
#pragma warning(error: 5286)  // Makes this a hard error
```

### When It Appears
- VS 2019 16.8+
- With `/std:c++20` or `/std:c++latest`
- Level 1 warning (enabled by default)

### Why It's Deprecated
C++20 considers this a logic error - comparing apples to oranges.

---

## C5287: Assignment Operator Implicitly Deleted

### What Triggers It
Class has members that prevent default assignment operator (references, const members, etc.).

### Example
```cpp
struct Data {
	int& ref;  // Reference member

	Data& operator=(const Data&) = default;  // ❌ C5287
};
```

### How to Fix
```cpp
// Option 1: Remove reference/const members
struct Data {
	int* ptr;  // Use pointer instead

	Data& operator=(const Data&) = default;  // ✅
};

// Option 2: Manually implement assignment
struct Data {
	int& ref;

	Data& operator=(const Data& other) {  // ✅
		// Custom logic - can't reassign reference
		// Maybe copy the value ref points to?
		return *this;
	}
};

// Option 3: Explicitly delete if assignment doesn't make sense
struct Data {
	int& ref;

	Data& operator=(const Data&) = delete;  // ✅ Intentional
};
```

### When It Appears
- VS 2017+
- Any C++ standard
- When explicitly defaulting implicitly-deleted special members

---

## C5292 & C5294: Enum/Float Comparison Deprecated

### What Triggers It
- **C5292:** `enum op float` operations
- **C5294:** `float op enum` operations

Both deprecated in C++20.

### Example
```cpp
enum Priority { Low = 1, High = 10 };

double threshold = 5.5;

if (High > threshold) {}      // ❌ C5292
if (threshold < Low) {}       // ❌ C5294
```

### How to Fix
```cpp
// Cast enum to numeric type
if (static_cast<int>(High) > threshold) {}     // ✅
if (threshold < static_cast<int>(Low)) {}      // ✅

// Or use enum class with explicit static_cast
enum class Priority { Low = 1, High = 10 };
if (static_cast<int>(Priority::High) > threshold) {}  // ✅
```

### When It Appears
- VS 2019 16.10+
- With `/std:c++20` or `/std:c++latest`
- Warning level 3

### Why It's Deprecated
C++20 considers mixing enums with floating-point error-prone.

---

## C5295: Array Too Small for Null Terminator

### What Triggers It
Character array sized exactly for the string literal without space for `'\0'`.

### Example
```cpp
char name[5] = "Hello";  // ❌ C5295 - needs 6 elements
```

### How to Fix
```cpp
// Option 1: Correct size
char name[6] = "Hello";  // ✅

// Option 2: Let compiler deduce size
char name[] = "Hello";  // ✅ Automatically 6 elements

// Option 3: Use std::string (best practice)
std::string name = "Hello";  // ✅

// Option 4: Use std::array
std::array<char, 6> name = {'H', 'e', 'l', 'l', 'o', '\0'};  // ✅
```

### When It Appears
- VS 2019+
- All C++ standards
- Warning level 4

---

## C5311: Concept Constraint Not Satisfied

### What Triggers It
Template argument doesn't satisfy a C++20 concept.

### Example
```cpp
template<typename T>
concept Integral = std::is_integral_v<T>;

template<Integral T>
void process(T value) {}

process(3.14);  // ❌ C5311 - double doesn't satisfy Integral
```

### How to Fix
```cpp
// Option 1: Use correct type
process(42);  // ✅ int satisfies Integral

// Option 2: Relax the concept
template<typename T>
concept Numeric = std::is_arithmetic_v<T>;

template<Numeric T>
void process(T value) {}

process(3.14);  // ✅ Now works with double

// Option 3: Add overload for other types
template<std::floating_point T>
void process(T value) {}  // ✅ Separate overload for floats
```

### When It Appears
- VS 2019 16.8+ with `/std:c++20`
- Only with C++20 concepts
- Compile error (not a warning)

---

## C5333: Local Function Definition Forbidden

### What Triggers It
Defining a function inside another function (nested functions).

### Example
```cpp
void outer() {
	void inner() {  // ❌ C5333
		std::cout << "Nested function\n";
	}

	inner();
}
```

### How to Fix
```cpp
// Option 1: Use lambda (best practice)
void outer() {
	auto inner = []() {  // ✅
		std::cout << "Lambda\n";
	};

	inner();
}

// Option 2: Move to namespace scope
void inner() {
	std::cout << "Global function\n";
}

void outer() {
	inner();  // ✅
}

// Option 3: Use std::function
void outer() {
	std::function<void()> inner = []() {  // ✅
		std::cout << "Function object\n";
	};

	inner();
}
```

### When It Appears
- VS 2017+
- All C++ standards (never allowed in standard C++)
- Compile error

### Note
GCC allows nested functions as an extension. MSVC never has.

---

## How to Enable/Disable These Warnings

### Enable Specific Warnings
```cpp
#pragma warning(default: 5286)  // Enable at default level
#pragma warning(1: 5292)        // Enable at level 1
```

### Treat as Error
```cpp
#pragma warning(error: 5286)    // Any use becomes compile error
```

### Disable Specific Warnings
```cpp
#pragma warning(disable: 5295)  // Suppress C5295
```

### Command Line Options
```bash
# Enable all conformance warnings
cl /W4 /permissive- file.cpp

# Treat specific warning as error
cl /we5286 file.cpp

# Disable specific warning
cl /wd5295 file.cpp
```

### CMakeLists.txt
```cmake
# Enable stricter conformance
target_compile_options(MyTarget PRIVATE
	/W4
	/permissive-
	/we5286    # Treat enum comparison as error
)
```

---

## Summary

These errors represent **modern C++ conformance improvements**:

- **C5272, C5333:** Catch template/syntax errors
- **C5286, C5292, C5294:** Enforce C++20 enum safety
- **C5287:** Detect implicitly-deleted operators
- **C5295:** Prevent buffer overruns
- **C5311:** Enforce concept constraints

Most of these are **warnings** that can be promoted to errors for safer code.

### Recommendation

✅ **Enable all** - These catch real bugs  
✅ **Use `/permissive-`** - For standards conformance  
✅ **Treat as errors** in new code - Prevent issues early  
⚠️ **Disable selectively** in legacy code - During migration only

See `ModernConformanceErrors.cpp` for working code examples!
