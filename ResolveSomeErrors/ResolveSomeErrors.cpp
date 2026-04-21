#include <iostream>
#include <vector>
#include <type_traits>

void myFunc() {
	std::cout << "Hello\n";
}

enum Color { Red, Blue };
enum Size { Small, Large };
void comparison();

void colorComparison() {
	bool same = (Color::Red == Size::Small);
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
