#include <iostream>
#include <vector>
#include <type_traits>

void myFunc() {
	std::cout << "Hello\n";
}

template<auto F>
struct Wrapper {};

Wrapper<myFunc> w1;

enum Color { Red, Blue };
enum Size { Small, Large };

void colorCheck() {
	bool same = (Red == Small);
}

struct BadStruct {
	int& ref;

	BadStruct& operator=(const BadStruct&) = default;
};

enum Priority { Low = 1, High = 10 };

void castTest() {
	double threshold = 5.5;
	bool test1 = (High > threshold);
	bool test2 = (threshold < Low);
}

void triggerC5295() {
	char name[5] = "Hello";
}

template<typename T>
concept Integral = std::is_integral_v<T>;

template<Integral T>
void requiresInt(T value) {
	std::cout << value << std::endl;
}

void eventHandler() {
	requiresInt(42);
}

void comparison() {
	bool same = (Color::Red == Size::Small);
	std::cout << "Same: " << same << std::endl;
}

enum Priority2 { Low2 = 1, High2 = 10 };

void printGreeting() {
	char name[5] = "Hello";
	std::cout << "Name: " << name << std::endl;
}

int main() {
	comparison();
	castTest();
	printGreeting();
	return 0;
}
