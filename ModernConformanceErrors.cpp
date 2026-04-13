// Demonstration of Modern MSVC Conformance Errors
// These errors appear with strict C++20 conformance checking

#include <iostream>
#include <type_traits>

// ============================================================================
// C5272: Invalid use of function pointer as constant expression
// ============================================================================
void myFunction() {
	std::cout << "Function called" << std::endl;
}

template<auto F>
struct FunctionWrapper {};

void demonstrateC5272() {
	// ERROR C5272: Function pointer is not a valid template argument
	// FunctionWrapper<myFunction> wrapper;  

	// FIX: Use function pointer type explicitly
	template<void(*)()> struct FixedWrapper {};
	// FixedWrapper<&myFunction> fixedWrapper;
}

// ============================================================================
// C5286: Deprecated comparison between different enum types
// ============================================================================
enum class Color { Red, Green, Blue };
enum class Size { Small, Medium, Large };

void demonstrateC5286() {
	// ERROR C5286: Comparison between different enumerations deprecated in C++20
	// bool same = (Color::Red == Size::Small);

	// FIX: Don't compare different enum types, or cast to underlying type
	bool same = (static_cast<int>(Color::Red) == static_cast<int>(Size::Small));
}

// ============================================================================
// C5287: Assignment operator implicitly deleted
// ============================================================================
struct ProblematicStruct {
	int& reference;  // Reference member causes implicitly deleted assignment

	// ERROR C5287: Assignment operator is implicitly deleted
	// ProblematicStruct& operator=(const ProblematicStruct&) = default;
};

void demonstrateC5287() {
	int x = 10, y = 20;
	ProblematicStruct a{x};
	ProblematicStruct b{y};

	// ERROR: Would fail if assignment operator was enabled
	// a = b;  
}

// ============================================================================
// C5292 & C5294: Deprecated comparison between enum and floating-point
// ============================================================================
enum class Priority { Low = 1, Medium = 5, High = 10 };

void demonstrateC5292_C5294() {
	double threshold = 7.5;

	// ERROR C5292: Comparison between enumeration and floating-point deprecated
	// bool isHigh = (Priority::High > threshold);

	// ERROR C5294: Comparison between floating-point and enumeration deprecated  
	// bool isLow = (threshold < Priority::Low);

	// FIX: Cast enum to its underlying type
	bool isHigh = (static_cast<int>(Priority::High) > threshold);
	bool isLow = (threshold < static_cast<int>(Priority::Low));
}

// ============================================================================
// C5295: Array too small to include terminating null character
// ============================================================================
void demonstrateC5295() {
	// ERROR C5295: Array is too small (needs 6 elements, not 5)
	// char greeting[5] = "Hello";  // Needs room for '\0'

	// FIX: Correct size or use std::string
	char greeting[6] = "Hello";

	// Better: use std::string
	std::string betterGreeting = "Hello";
}

// ============================================================================
// C5311: Concept constraint not satisfied
// ============================================================================
#if __cplusplus >= 202002L  // C++20 or later

template<typename T>
concept Numeric = std::is_arithmetic_v<T>;

template<Numeric T>
void processNumber(T value) {
	std::cout << "Processing: " << value << std::endl;
}

void demonstrateC5311() {
	processNumber(42);    // OK - int satisfies Numeric
	processNumber(3.14);  // OK - double satisfies Numeric

	// ERROR C5311: Concept 'Numeric' evaluated to false for 'std::string'
	// processNumber(std::string("text"));

	// FIX: Use a type that satisfies the concept
	// Or remove the concept constraint
}

#endif

// ============================================================================
// C5333: Local function definitions forbidden
// ============================================================================
void demonstrateC5333() {
	// ERROR C5333: Cannot define function inside another function
	// void localFunction() {
	//     std::cout << "Local function" << std::endl;
	// }

	// FIX: Use lambda instead
	auto lambda = []() {
		std::cout << "Lambda function" << std::endl;
	};

	lambda();
}

// ============================================================================
// Main function demonstrating all fixes
// ============================================================================
int main() {
	std::cout << "=== Modern MSVC Conformance Error Demonstrations ===" << std::endl;
	std::cout << std::endl;

	std::cout << "All error examples are commented out." << std::endl;
	std::cout << "Uncomment them to see the actual errors." << std::endl;
	std::cout << std::endl;

	std::cout << "Running fixed versions..." << std::endl;
	demonstrateC5286();
	demonstrateC5287();
	demonstrateC5292_C5294();
	demonstrateC5295();

	#if __cplusplus >= 202002L
	demonstrateC5311();
	#endif

	demonstrateC5333();

	std::cout << std::endl;
	std::cout << "All demonstrations completed successfully!" << std::endl;

	return 0;
}
