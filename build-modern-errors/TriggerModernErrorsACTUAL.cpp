// TriggerModernErrorsACTUAL.cpp
// This file ACTUALLY contains the errors - will not compile!
// Use this to see what the errors look like

#include <iostream>
#include <vector>
#include <type_traits>

// ============================================================================
// ACTUAL ERROR C5286: Comparing different enum types
// ============================================================================
enum class Color { Red, Blue };
enum class Size { Small, Large };

void actualC5286() {
	bool same = (Color::Red == Size::Small);  // WARNING C5286
	std::cout << "Same: " << same << std::endl;
}


// ============================================================================
// ACTUAL ERROR C5292/C5294: Enum and float comparison
// ============================================================================
enum Priority { Low = 1, High = 10 };

void actualC5292_C5294() {
	double threshold = 5.5;

	bool test1 = (High > threshold);       // WARNING C5292
	bool test2 = (threshold < Low);        // WARNING C5294

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
