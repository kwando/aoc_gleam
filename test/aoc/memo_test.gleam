import aoc/memo

pub fn ets_test() {
  assert 573_147_844_013_817_084_101
    == {
      use cache <- memo.create()
      fib(cache, 100)
    }
}

fn fib(cache, n: Int) {
  use <- memo.memoize(cache, n)
  case n {
    _ if n <= 1 -> 1
    n -> fib(cache, n - 1) + fib(cache, n - 2)
  }
}
