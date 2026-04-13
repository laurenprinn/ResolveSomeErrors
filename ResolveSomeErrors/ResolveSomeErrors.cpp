// TriggerModernErrorsACTUAL.cpp
// This file ACTUALLY contains the errors - will not compile!
// Use this to see what the errors look like

#include <iostream>
#include <vector>
#include <type_traits>

// ============================================================================
// INTENTIONAL ERROR C5272: Invalid function pointer in template
// ============================================================================
void myFunc() {
	std::cout << "Hello\n";
}

#if __cplusplus >= 201703L || _MSVC_LANG >= 201703L
// C++17 or later: template<auto> is supported
template<auto F>
struct Wrapper {};

Wrapper<myFunc> w1;  // ERROR C5272
#else
// C++14: Use explicit function pointer type
template<void(*F)()>
struct Wrapper {};

Wrapper<myFunc> w1;  // Compiles in C++14
#endif


// ============================================================================
// INTENTIONAL ERROR C5286: Comparing different enum types
// ============================================================================
enum Color { Red, Blue };
enum Size { Small, Large };

void triggerC5286() {
	// UNCOMMENT to trigger C5286:
	bool same = (Red == Small);  // WARNING C5054 & 4189
}


// ============================================================================
// INTENTIONAL ERROR C5287: Implicitly deleted assignment
// ============================================================================
struct BadStruct {
	int& ref;

	// UNCOMMENT to trigger C5287:
	BadStruct& operator=(const BadStruct&) = default;  // WARNING C5287
};


// ============================================================================
// INTENTIONAL ERROR C5292/C5294: Enum and float comparison
// ============================================================================
enum Priority { Low = 1, High = 10 };

void triggerC5292_C5294() {
	double threshold = 5.5;

	// UNCOMMENT to trigger C5292:
	bool test1 = (High > threshold);  // WARNING C5055 & C4189

	// UNCOMMENT to trigger C5294:
	bool test2 = (threshold < Low);  // WARNING C5055 & C4189
}


// ============================================================================
// INTENTIONAL ERROR C5295: Array too small for null terminator
// ============================================================================
void triggerC5295() {
	// UNCOMMENT to trigger C5295:
	char name[5] = "Hello";  // WARNING C2117
}


// ============================================================================
// INTENTIONAL ERROR C5311: Concept not satisfied
// ============================================================================
#if __cplusplus >= 202002L

template<typename T>
concept Integral = std::is_integral_v<T>;

template<Integral T>
void requiresInt(T value) {
	std::cout << value << std::endl;
}

void triggerC5311() {
	requiresInt(42);  // OK

	// UNCOMMENT to trigger C5311:
	// requiresInt(3.14);  // ERROR C5311 - double doesn't satisfy Integral
}

#endif


// ============================================================================
// INTENTIONAL ERROR C5333: Nested function definition
// ============================================================================
void triggerC5333() {
	// UNCOMMENT to trigger C5333:
	// void nested() {  // ERROR C5333
	//     std::cout << "Nested\n";
	// }
}

// ============================================================================
// ACTUAL ERROR C5286: Comparing different enum types
// ============================================================================

void actualC5286() {
	bool same = (Color::Red == Size::Small);  // WARNING C5286
	std::cout << "Same: " << same << std::endl;
}


// ============================================================================
// ACTUAL ERROR C5055: Enum and float comparison (deprecated)
// ============================================================================
enum Priority2 { Low2 = 1, High2 = 10 };

void actualC5292_C5294() {
	double threshold = 5.5;

	bool test1 = (High2 > threshold);       // WARNING C5055
	bool test2 = (threshold < Low2);        // WARNING C5055

	std::cout << "Tests: " << test1 << ", " << test2 << std::endl;
}


// ============================================================================
// ACTUAL ERROR C5295: Array too small for null terminator
// ============================================================================
void actualC5295() {
	char name[5] = "Hello";  // WARNING C5295 - needs 6
	std::cout << "Name: " << name << std::endl;
}


// ============================================================================
// Main - This will generate warnings/errors when compiled
// ============================================================================
int main() {
	std::cout << "==========================================\n";
	std::cout << " Testing Modern MSVC Warnings\n";
	std::cout << "==========================================\n\n";

	std::cout << "This file contains actual warning-triggering code.\n";
	std::cout << "Build with /W4 to see the warnings.\n";
	std::cout << "Build with /WX to treat them as errors.\n\n";

	actualC5286();
	actualC5292_C5294();
	actualC5295();

	std::cout << "\nIf you're seeing this, warnings didn't stop the build!\n";

	return 0;
}
