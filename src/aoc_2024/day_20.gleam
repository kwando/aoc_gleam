import aoc/vec2.{type Vec2, manhattan_distance}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option
import gleam/string

pub fn pt_1(input: ParseResult) {
  let map = input.0
  let assert Ok([start]) = dict.get(input.1, "S")
  let assert Ok([goal]) = dict.get(input.1, "E")

  let assert Ok(path) = dfs_search(start, goal, map, [])
  count_cheats(path, cheat_duration: 2, threshold: 100)
}

pub fn pt_2(input: ParseResult) {
  let map = input.0
  let assert Ok([start]) = dict.get(input.1, "S")
  let assert Ok([goal]) = dict.get(input.1, "E")

  let assert Ok(path) = dfs_search(start, goal, map, [])
  count_cheats(path, cheat_duration: 20, threshold: 100)
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

fn dfs_search(
  position: Vec2,
  goal: Vec2,
  blocks: dict.Dict(Vec2, String),
  path: List(Vec2),
) {
  case position == goal {
    True -> Ok(list.reverse([goal, ..path]))
    False -> {
      // there should only be one option..
      let assert [next] =
        list.filter_map(directions, fn(dir) {
          let next_pos = vec2.translate(position, dir)
          case is_free(blocks, next_pos) {
            True -> Ok(next_pos)
            False -> Error(Nil)
          }
        })

      dfs_search(next, goal, blocks |> dict.insert(position, "#"), [
        position,
        ..path
      ])
    }
  }
}

fn is_free(map, position) {
  dict.get(map, position) == Ok(".")
}
