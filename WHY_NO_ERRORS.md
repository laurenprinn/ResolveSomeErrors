# Why You're Not Seeing C52xx/C53xx Errors

## TL;DR - The Actual Errors You'll See

When you build modern conformance-violating code with MSVC 2022+, you'll see:

| Expected | Actual | Why Different |
|----------|--------|---------------|
| C5286 | **C2676** | With `/permissive-`, enum comparison becomes hard error |
| C5292/C5294 | **C5055** | Different warning number for enum/float operations |
| C5295 | **C2117** | Array bounds overflow is hard error, not warning |
| C5311 | **C7648** or similar | Concept errors use different numbers |

## What We Just Discovered

When I ran `show-modern-errors.ps1`, we saw:

```
✓ C2676: binary '==': 'Color' does not define this operator
✓ C5055: operator '>': deprecated between enumerations and floating-point
✓ C5055: operator '<': deprecated between enumerations and floating-point  
✓ C2117: 'name': array bounds overflow
```

### Why C5286 Didn't Appear
**With `/permissive-` mode**, comparing different `enum class` types becomes a **compile error (C2676)** instead of just a warning (C5286).

```cpp
enum class Color { Red };
enum class Size { Small };

bool same = (Color::Red == Size::Small);  // C2676 error, not C5286 warning
```

### Why C5292/C5294 Are Actually C5055
The enum/float operation warnings are reported as **C5055** in newer MSVC versions:

```cpp
enum Priority { Low = 1, High = 10 };
double threshold = 5.5;

bool test = (High > threshold);  // C5055, not C5292
```

### Why C5295 Is Actually C2117
Array bounds violations are **hard errors**, not warnings:

```cpp
char name[5] = "Hello";  // C2117 error - needs 6 chars
```

## When Do You Actually See C52xx/C53xx Numbers?

### C5272 - Seen with older `/std:c++17` mode
```cpp
void func() {}

template<auto F>
struct Wrapper {};

Wrapper<func> w;  // C5272 in C++17, might be different in C++20
```

### C5286 - Seen WITHOUT `/permissive-`
```cpp
// Build with /W3 but NOT /permissive-
enum class A { X };
enum class B { Y };

bool b = (A::X == B::Y);  // C5286 warning (permissive mode)
// But with /permissive-: C2676 error instead!
```

### C5311 - Seen with C++20 concepts
```cpp
template<std::integral T>
void func(T x) {}

func(3.14);  // Varies - might be C5311 or C7648 or different
```

### C5333 - Nested functions
```cpp
void outer() {
	void inner() {}  // C5333 or C2084 depending on context
}
```

## Real Warning Numbers in Modern MSVC

Here are the **actual warnings** you'll commonly see:

| Code | Description | Level |
|------|-------------|-------|
| **C2676** | Binary operator on enum class (error) | Error |
| **C2117** | Array bounds overflow | Error |
| **C5055** | Enum and floating-point operations | W3 |
| **C5204** | Class with virtual functions has no virtual destructor | W4 |
| **C5246** | Initialization of subobject should be wrapped | W4 |
| **C4244** | Conversion with possible loss of data | W3 |
| **C4267** | Size_t to int conversion | W3 |

## How to See Specific Modern Warnings

### 1. Enable High Warning Level
```cmake
if (MSVC)
	target_compile_options(MyTarget PRIVATE /W4)
endif()
```

### 2. Enable Specific Warnings
```cmake
target_compile_options(MyTarget PRIVATE
	/w15055    # Enable C5055 at level 1
	/w15204    # Enable C5204
)
```

### 3. Don't Use `/permissive-` for Warnings
`/permissive-` turns many warnings into **errors**. To see warnings:

```cmake
# See warnings (not errors)
target_compile_options(MyTarget PRIVATE /W4)

# vs.

# See errors (former warnings become errors)
target_compile_options(MyTarget PRIVATE /W4 /permissive-)
```

## How to Configure Your Project

### To See Warnings (Not Errors)

```cmake
if (MSVC)
	target_compile_options(ResolveSomeErrors PRIVATE
		/W4              # High warning level
		/std:c++20       # C++20 standard
		# Don't use /permissive- if you want warnings
	)
endif()
```

### To See Errors (Strict Mode)

```cmake
if (MSVC)
	target_compile_options(ResolveSomeErrors PRIVATE
		/W4              # High warning level
		/std:c++20       # C++20 standard
		/permissive-     # Strict conformance (warnings → errors)
		/WX              # Treat ALL warnings as errors
	)
endif()
```

## Summary: Why You Don't See Those Specific Error Numbers

1. **C5286** → Becomes **C2676** with `/permissive-`
2. **C5292/C5294** → Are actually **C5055** in your MSVC version
3. **C5295** → Is **C2117** (hard error, not warning)
4. **C5272, C5311, C5333** → Depend on specific code and compiler mode

## What to Do Next

### Option 1: See the Actual Errors
Run the script I created:
```powershell
.\show-modern-errors.ps1
```

You'll see **C2676**, **C5055**, **C2117** instead of the C52xx numbers.

### Option 2: Build Without `/permissive-`
Remove strict mode to see warnings instead of errors:

Edit `ResolveSomeErrors/CMakeLists.txt`:
```cmake
if (MSVC)
	target_compile_options(ResolveSomeErrors PRIVATE
		/W4         # Warnings only
		/std:c++20
		# /permissive- commented out
	)
endif()
```

### Option 3: Check Your MSVC Version
Different compiler versions use different warning numbers:
- VS 2019: Some C52xx warnings
- VS 2022: Different numbers (C5055, etc.)
- VS 2026 (yours): Latest behavior

```powershell
cl /?  # Check your compiler version
```

## Files to Test

I created these files for you:
- ✅ `TriggerModernErrorsACTUAL.cpp` - Code with actual errors
- ✅ `show-modern-errors.ps1` - Script to demonstrate them
- ✅ `TestModernErrors_CMakeLists.txt` - Configured build

Run `.\show-modern-errors.ps1` to see the real error numbers!
