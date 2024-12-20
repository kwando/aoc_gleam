import aoc/vec2.{type Vec2, manhattan_distance, translate}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import gleamy/priority_queue

pub fn pt_1(input: ParseResult) {
  let map = input.0
  let assert Ok([start]) = dict.get(input.1, "S")
  let assert Ok([goal]) = dict.get(input.1, "E")
  let q =
    priority_queue.from_list(
      [Next(length: 0, score: 0, position: start, path: [start])],
      fn(a, b) { int.compare(a.score, b.score) },
    )

  let assert Ok(res) = find_path(q, goal, map)

  let #(length_left, _) =
    list.fold(res.path |> list.reverse, #(dict.new(), 0), fn(acc, pos) {
      #(dict.insert(acc.0, pos, acc.1), acc.1 + 1)
    })

  fold_path(res.path, dict.new(), length_left, 2)
  |> dict.fold(0, fn(agg, key, value) {
    case key {
      key if key >= 100 -> agg + value
      _ -> agg
    }
  })
}

pub fn pt_2(input: ParseResult) {
  let map = input.0
  let assert Ok([start]) = dict.get(input.1, "S")
  let assert Ok([goal]) = dict.get(input.1, "E")
  let q =
    priority_queue.from_list(
      [Next(length: 0, score: 0, position: start, path: [start])],
      fn(a, b) { int.compare(a.score, b.score) },
    )

  let assert Ok(res) = find_path(q, goal, map)

  let #(length_left, _) =
    list.fold(res.path |> list.reverse, #(dict.new(), 0), fn(acc, pos) {
      #(dict.insert(acc.0, pos, acc.1), acc.1 + 1)
    })

  fold_path(res.path, dict.new(), length_left, 20)
  |> dict.fold(0, fn(agg, key, value) {
    case key {
      key if key >= 100 -> agg + value
      _ -> agg
    }
  })
}

fn fold_path(path, count, length_left, max_distance) {
  case path {
    [] -> count
    [pos, ..rest] -> {
      fold_path(
        rest,
        {
          // find positions closer to the goal we could jump to
          let options =
            list.filter(rest, fn(p) {
              manhattan_distance(pos, p) <= max_distance
            })
          use count, check_pos <- list.fold(options, count)
          let assert Ok(steps_from_here) = dict.get(length_left, pos)
          case dict.get(length_left, check_pos) {
            Ok(value) -> {
              let saved_steps =
                steps_from_here
                - int.min(
                  value + manhattan_distance(pos, check_pos),
                  steps_from_here,
                )

              dict.upsert(count, saved_steps, fn(x) { option.unwrap(x, 0) + 1 })
            }
            Error(Nil) -> count
          }
        },
        length_left,
        max_distance,
      )
    }
  }
}

pub type ParseResult =
  #(dict.Dict(Vec2, String), dict.Dict(String, List(Vec2)))

pub fn parse(input: String) -> ParseResult {
  use acc, line, row <- list.index_fold(string.split(input, "\n"), #(
    dict.new(),
    dict.new(),
  ))
  use acc, cell, col <- list.index_fold(string.split(line, ""), acc)
  case cell {
    "." | "#" -> #(dict.insert(acc.0, #(col, row), cell), acc.1)
    x -> #(
      dict.insert(acc.0, #(col, row), "."),
      dict.upsert(acc.1, x, fn(prev) {
        [#(col, row), ..option.unwrap(prev, [])]
      }),
    )
  }
}

pub type Next {
  Next(score: Int, length: Int, position: vec2.Vec2, path: List(Vec2))
}

const directions = [#(0, 1), #(1, 0), #(-1, 0), #(0, -1)]

fn find_path(queue, goal: Vec2, blocks: dict.Dict(Vec2, String)) {
  case priority_queue.pop(queue) {
    Error(_) -> Error(Nil)
    Ok(#(Next(..) as head, remaining)) -> {
      case head.position == goal {
        True -> Ok(head)
        False -> {
          let updated_queue =
            list.fold(directions, remaining, fn(queue, direction) {
              let next_pos = vec2.translate(head.position, direction)
              case is_free(blocks, next_pos) {
                True ->
                  priority_queue.push(
                    queue,
                    Next(
                      length: head.length + 1,
                      score: head.length
                        + 1
                        + manhattan_distance(next_pos, goal),
                      position: next_pos,
                      path: [next_pos, ..head.path],
                    ),
                  )
                False -> queue
              }
            })

          find_path(
            updated_queue,
            goal,
            blocks |> dict.insert(head.position, "#"),
          )
        }
      }
    }
  }
}

fn is_free(map, position) {
  dict.get(map, position) == Ok(".")
}
