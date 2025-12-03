import gleam/int
import gleam/list
import gleam/pair
import gleam/string

pub fn pt_1(banks: ParseResult) -> Int {
  max_joltage_sum(banks, 2)
}

pub fn pt_2(banks: ParseResult) -> Int {
  max_joltage_sum(banks, 12)
}

fn max_joltage_sum(banks: List(List(Int)), number_of_batteries: Int) -> Int {
  use sum, bank <- list.fold(banks, 0)
  sum + max_joltage(bank, number_of_batteries)
}

fn max_joltage(first: List(Int), length: Int) -> Int {
  list.range(1, length)
  |> list.reverse
  |> list.fold(#(0, first), fn(acc, batteries_needed) {
    let #(max, rest) =
      max_joltage_loop(
        acc.1,
        current_max: 0,
        current_max_tail: acc.1,
        batteries_left: list.length(acc.1),
        batteries_needed:,
      )

    #(acc.0 * 10 + max, rest)
  })
  |> pair.first
}

fn max_joltage_loop(
  input: List(Int),
  current_max current_max: Int,
  current_max_tail current_max_tail: List(Int),
  batteries_left batteries_left: Int,
  batteries_needed batteries_needed: Int,
) {
  case batteries_left < batteries_needed {
    True -> #(current_max, current_max_tail)
    False -> {
      case input {
        [a, ..rest] if a > current_max -> {
          max_joltage_loop(rest, a, rest, batteries_left - 1, batteries_needed)
        }
        [_, ..rest] ->
          max_joltage_loop(
            rest,
            current_max,
            current_max_tail,
            batteries_left - 1,
            batteries_needed,
          )
        _ -> panic as "i know what I'm doing.. sometimes"
      }
    }
  }
}

pub type ParseResult =
  List(List(Int))

pub fn parse(input: String) -> ParseResult {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(joltages) =
      line
      |> string.split("")
      |> list.try_map(int.parse)

    joltages
  })
}
