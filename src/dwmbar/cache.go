package main

import (
	"fmt"
)

func cache[C any, T fmt.Stringer](cacheInput C, output func(C) (T, error)) getter[T] {
	return func() (T, error) { return output(cacheInput) }
}
