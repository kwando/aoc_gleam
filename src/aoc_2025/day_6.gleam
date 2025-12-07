import gleam/int
import gleam/list
import gleam/string

pub type Operation {
  Add
  Multiply
}

pub fn pt_1(input: String) {
  let assert [operations, ..args] =
    input
    |> string.trim
    |> string.split("\n")
    |> list.reverse

  let ops = parse_ops(operations)

  let assert Ok(args) =
    list.try_map(args, fn(line) {
      string.split(line, " ")
      |> list.filter(fn(x) { x != "" })
      |> list.try_map(int.parse)
    })

  let args = list.transpose(args)

  use sum, acc <- list.fold(list.zip(ops, args), 0)
  sum + acc.0(acc.1)
}

pub fn pt_2(input: String) {
  let assert [operations, ..args] =
    input
    |> string.trim
    |> string.split("\n")
    |> list.reverse

  let ops = parse_ops(operations)

  let assert Ok(args) =
    args
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(fn(line) {
      list.reverse(line)
      |> string.concat
      |> string.trim
    })
    |> string.join(" ")
    |> string.split("  ")
    |> list.try_map(fn(line) {
      line
      |> string.split(" ")
      |> list.try_map(int.parse)
    })

  use sum, acc <- list.fold(list.zip(ops, args), 0)
  sum + acc.0(acc.1)
}

fn parse_ops(operations: String) -> List(fn(List(Int)) -> Int) {
  operations
  |> string.split(" ")
  |> list.filter(fn(x) { x != "" })
  |> list.map(fn(op) {
    case op {
      "*" -> list.fold(_, 1, int.multiply)
      "+" -> int.sum
      x -> panic as { "bad operation " <> x }
    }
  })
}
