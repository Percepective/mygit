#include <functional>
#include "a.h"
template<typename T>
struct Maybe final {
	T x;
};

Maybe<int> Foo() {
}

Maybe<int> Bar() {
}

struct A final {
	static Maybe<int> StaticBar() { }
	Maybe<int> MethodBar() {}
};

int Demo() {
}

Maybe<int> Wrapper(Maybe<int>) {
}

Maybe<int> ErrorWrapper(Maybe<int>) {
}

int Demo(std::function<Maybe<int>()> DemoArg) {
	DemoArg();
	Wrapper(DemoArg());
}

int main(){
	Wrapper(Foo());
	ErrorWrapper(Bar());
	auto x = Bar();
	Bar();
	return 0;
}
