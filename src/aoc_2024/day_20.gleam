import aoc/vec2.{type Vec2, manhattan_distance}
import gleam/bool
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

  count_cheats(res.path, cheat_duration: 2, threshold: 100)
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
  count_cheats(res.path, cheat_duration: 20, threshold: 100)
}

fn count_cheats(path, cheat_duration max_distance: Int, threshold threshold) {
  // calculate the distance to goal from every position on the path
  let #(distances, _) =
    list.fold(path |> list.reverse, #(dict.new(), 0), fn(acc, pos) {
      #(dict.insert(acc.0, pos, acc.1), acc.1 + 1)
    })

  count_cheats_loop(path, 0, distances, max_distance, threshold)
}

fn count_cheats_loop(
  path,
  count: Int,
  distances,
  cheat_duration max_distance: Int,
  threshold threshold,
) {
  case path {
    [] -> count
    [pos, ..rest] -> {
      count_cheats_loop(
        rest,
        count
          + {
          use cheat_position <- list.count(rest)
          let cheat_distance = manhattan_distance(pos, cheat_position)
          use <- bool.guard(when: cheat_distance > max_distance, return: False)

          let assert Ok(remaining_steps) = dict.get(distances, pos)
          let assert Ok(steps_after_cheat) = dict.get(distances, cheat_position)
          remaining_steps - steps_after_cheat - cheat_distance >= threshold
        },
        distances,
        max_distance,
        threshold,
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
