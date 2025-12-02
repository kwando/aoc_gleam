import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub fn pt_1(input: ParseResult) {
  let is_silly = fn(a: Int) {
    let n = int.to_string(a)
    let len = string.length(n)
    case len % 2 == 1 {
      True -> False
      False -> {
        string.slice(n, 0, len / 2) == string.slice(n, len / 2, len - 1)
      }
    }
  }
  list.fold(input, 0, fn(sum, range) {
    let silly_numbers = list.filter(list.range(range.0, range.1), is_silly)
    sum + int.sum(silly_numbers)
  })
}

pub fn pt_2(input: ParseResult) {
  possible_values()
  |> set.fold(0, fn(sum, number) {
    case list.any(input, fn(range) { number >= range.0 && number <= range.1 }) {
      False -> sum
      True -> sum + number
    }
  })
}

pub type ParseResult =
  List(#(Int, Int))

pub fn parse(input: String) -> ParseResult {
  input
  |> string.trim
  |> string.split(",")
  |> list.map(fn(range) {
    let assert Ok([start, end]) =
      string.split(range, "-")
      |> list.try_map(int.parse)
      as { "failed for " <> range }

    #(start, end)
  })
}

fn possible_values() {
  [
    combinations(1, 9, 10),
    combinations(10, 99, 100),
    combinations(100, 999, 1000),
    combinations(1000, 9999, 10_000),
    combinations(10_000, 99_999, 100_000),
    combinations(100_000, 999_999, 1_000_000),
  ]
  |> list.flatten
  |> set.from_list
}

fn combinations(from, to, factor) {
  let max_value = 100_000_000
  list.range(from, to)
  |> list.flat_map(fn(seed) { grow_until(seed, factor, seed, max_value, []) })
}

pub fn grow_until(acc, factor, seed, max_value, result) {
  case acc < max_value {
    True ->
      grow_until(acc * factor + seed, factor, seed, max_value, [
        acc * factor + seed,
        ..result
      ])
    False -> result |> list.reverse
  }
}
