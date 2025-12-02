import gleam/int
import gleam/list
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
  input
  |> list.fold(0, fn(sum, range) {
    let silly_numbers =
      list.filter(list.range(int.max(range.0, 10), range.1), is_silly)

    sum + int.sum(silly_numbers)
  })
}

fn is_silly(num: Int) {
  let num_str = int.to_string(num)
  let len = string.length(num_str)

  list.range(1, len / 2)
  |> list.map(string.slice(num_str, 0, _))
  |> list.any(is_repeated(num_str, _))
}

fn is_repeated(input: String, seq: String) {
  case input, string.starts_with(input, seq) {
    "", _ -> True
    _, True -> is_repeated(string.drop_start(input, string.length(seq)), seq)
    _, False -> False
  }
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
