package main

import (
	"fmt"
)

func cache[
	C any,
	T fmt.Stringer, // The string in the bar
](
	cacheInput C,
	output func(C) (T, error),
) (
	getter[T],
	error,
) {
	return func() (T, error) {
		return output(cacheInput)
	}, nil
}
