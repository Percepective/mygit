#include <functional>
#include "a.h"
template<typename T>
struct Maybe final {
	T x;
};

Maybe<int> Wrapper(Maybe<int>) {
}

Maybe<int> ErrorWrapper(Maybe<int>) {
}
