import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

pub fn pt_1(input: #(Int, List(List(Int)))) {
  let #(start, splitters) = input
  let start = set.new() |> set.insert(start)

  {
    use acc, splitters <- list.fold(splitters, #(start, 0))
    use acc, splitter <- list.fold(splitters, acc)
    let #(beams, split_counts) = acc

    case set.contains(beams, splitter) {
      False -> acc
      True -> #(
        beams
          |> set.delete(splitter)
          |> set.insert(splitter - 1)
          |> set.insert(splitter + 1),
        split_counts + 1,
      )
    }
  }.1
}

pub fn pt_2(input: #(Int, List(List(Int)))) {
  let #(start, splitters) = input
  let start = dict.new() |> dict.insert(start, 1)

  {
    use beams, splitters <- list.fold(splitters, start)
    use beams, splitter <- list.fold(splitters, beams)
    case dict.get(beams, splitter) {
      Error(_) -> beams
      Ok(current) -> {
        beams
        |> dict.delete(splitter)
        |> dict.upsert(splitter - 1, fn(tc) {
          case tc {
            None -> current
            Some(tc) -> tc + current
          }
        })
        |> dict.upsert(splitter + 1, fn(tc) {
          case tc {
            None -> current
            Some(tc) -> tc + current
          }
        })
      }
    }
  }
  |> dict.values
  |> int.sum
}

pub fn parse(input: String) -> #(Int, List(List(Int))) {
  let splitters =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      list.index_fold(string.split(line, ""), [], fn(acc, cell, col) {
        case cell {
          "S" -> [col, ..acc]
          "^" -> [col, ..acc]
          _ -> acc
        }
      })
    })
    |> list.filter(fn(x) { x != [] })

  let assert [[start], ..splitters] = splitters

  #(start, splitters)
}
