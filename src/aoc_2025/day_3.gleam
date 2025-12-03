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

fn max_joltage(bank: List(Int), bank_size: Int) -> Int {
  list.range(bank_size, 1)
  |> list.fold(#(0, bank, list.length(bank)), fn(acc, batteries_needed) {
    let #(max, rest, tail_length) =
      max_joltage_loop(
        acc.1,
        current_max: 0,
        current_max_tail: acc.1,
        current_max_tail_length: acc.2,
        batteries_left: list.length(acc.1),
        batteries_needed:,
      )
    #(acc.0 * 10 + max, rest, tail_length)
  })
  |> fn(x) { x.0 }
}

fn max_joltage_loop(
  input: List(Int),
  current_max current_max: Int,
  current_max_tail current_max_tail: List(Int),
  current_max_tail_length current_max_tail_length: Int,
  batteries_left batteries_left: Int,
  batteries_needed batteries_needed: Int,
) {
  case batteries_left < batteries_needed {
    True -> #(current_max, current_max_tail, current_max_tail_length)
    False -> {
      case input {
        // we found a better batteru and still have batteries left
        [a, ..rest] if a > current_max -> {
          max_joltage_loop(
            rest,
            a,
            rest,
            batteries_left,
            batteries_left - 1,
            batteries_needed,
          )
        }
        [_, ..rest] ->
          max_joltage_loop(
            rest,
            current_max,
            current_max_tail,
            current_max_tail_length,
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
