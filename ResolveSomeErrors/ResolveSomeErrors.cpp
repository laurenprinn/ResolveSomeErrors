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

void comparison() {
	bool same = (Red == Small);
}

struct myStruct {
	int& ref;

	myStruct& operator=(const myStruct&) = default;
};

enum Priority { Low = 1, High = 10 };

void getThreshold() {
	double threshold = 5.5;
	bool test1 = (High > threshold);
	bool test2 = (threshold < Low);
}

void getName() {
	char name[5] = "Hello";
}

template<typename T>
concept Integral = std::is_integral_v<T>;

template<Integral T>
void printValue(T value) {
	std::cout << value << std::endl;
}

void eventHandler() {
	printValue(42);
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
	getThreshold();
	printGreeting();
	return 0;
}
