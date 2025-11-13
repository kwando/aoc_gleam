import aoc/memo

pub fn ets_test() {
  use cache <- memo.create()
  fib(cache, 100)
  |> echo
}

fn fib(cache, n: Int) {
  use <- memo.memoize(cache, n)
  case n {
    _ if n <= 1 -> 1
    n -> fib(cache, n - 1) + fib(cache, n - 2)
  }
}
