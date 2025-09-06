import gleam/bit_array
import gleam/list
import gleam/string
import rememo/memo

pub fn pt_1(input: ParseResult) {
  let #(towels, designs) = input
  list.count(designs, fn(design) {
    let res = possible(design, towels)
    res
  })
}

fn possible(design, towels) {
  case design {
    <<>> -> True
    design -> {
      list.fold_until(
        list.filter(towels, bit_array.starts_with(design, _)),
        False,
        fn(acc, towel) {
          let rest =
            design
            |> strip_prefix(towel)

          case possible(rest, towels) {
            True -> list.Stop(True)
            False -> list.Continue(acc)
          }
        },
      )
    }
  }
}

fn possible_designs(design, towels, cache) {
  use <- memo.memoize(cache, design)
  case design {
    <<>> -> 1
    remaining -> {
      let options = list.filter(towels, bit_array.starts_with(design, _))
      use acc, prefix <- list.fold(options, 0)
      let trimmed = strip_prefix(remaining, prefix)
      acc + possible_designs(trimmed, towels, cache)
    }
  }
}

fn strip_prefix(input, prefix) {
  case input, prefix {
    rest, <<>> -> rest
    <<a, rest:bits>>, <<b, rest_prefix:bits>> if a == b ->
      strip_prefix(rest, rest_prefix)
    _, _ -> panic as "could not strip prefix"
  }
}

pub fn pt_2(input: ParseResult) {
  let #(towels, designs) = input
  use cache <- memo.create()
  use acc, design <- list.fold(designs, 0)
  acc + possible_designs(design, towels, cache)
}

pub type ParseResult =
  #(List(BitArray), List(BitArray))

pub fn parse(input: String) -> ParseResult {
  let assert Ok(#(towels, designs)) = string.split_once(input, "\n\n")

  #(
    towels
      |> string.split(", ")
      |> list.map(bit_array.from_string),
    designs |> string.split("\n") |> list.map(bit_array.from_string),
  )
}
