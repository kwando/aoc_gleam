import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn pt_1(input: ParseResult) {
  let #(ranges, ingredients) = input
  use ingredient <- list.count(ingredients)
  use range <- list.any(ranges)
  ingredient >= range.0 && ingredient <= range.1
}

pub fn pt_2(input: ParseResult) {
  let #(ranges, _ingredients) = input
  use sum, range <- list.fold(merge_ranges(ranges), 0)
  sum + range.1 - range.0 + 1
}

fn merge_ranges(ranges: List(#(Int, Int))) {
  ranges
  |> list.sort(fn(r1, r2) {
    int.compare(r1.0, r2.0)
    |> order.break_tie(int.compare(r1.1, r2.1))
  })
  |> merge_ranges_loop([])
}

fn merge_ranges_loop(ranges, output) {
  case ranges {
    [] -> output |> list.reverse
    [#(a, b), #(c, d), ..rest] if c <= b ->
      merge_ranges_loop([#(a, int.max(b, d)), ..rest], output)
    [range, ..rest] -> merge_ranges_loop(rest, [range, ..output])
  }
}

pub type ParseResult =
  #(List(#(Int, Int)), List(Int))

pub fn parse(input: String) -> ParseResult {
  let assert [ranges, ingredients] =
    input
    |> string.split("\n\n")

  let ranges =
    ranges
    |> string.split("\n")
    |> list.flat_map(string.split(_, "-"))
    |> list.map(unsafe_int)
    |> list.sized_chunk(2)
    |> list.map(fn(range) {
      let assert [start, end] = range
      #(start, end)
    })

  let ingredients = ingredients |> string.split("\n") |> list.map(unsafe_int)
  #(ranges, ingredients)
}

fn unsafe_int(value) {
  let assert Ok(value) = int.parse(value)

  value
}
