import aoc/vec2
import gleam/list
import gleam/set
import gleam/string

pub fn pt_1(input: ParseResult) {
  remove_rolls(input).1
}

const offsets = [
  #(-1, -1),
  #(-1, 0),
  #(-1, 1),

  #(0, -1),
  #(0, 1),

  #(1, -1),
  #(1, 0),
  #(1, 1),
]

pub fn pt_2(input: ParseResult) {
  remove_rolls_rec(input, 0)
}

fn remove_rolls_rec(input, removed_rolls) {
  case remove_rolls(input) {
    #(_, 0) -> removed_rolls
    #(output, n) -> remove_rolls_rec(output, removed_rolls + n)
  }
}

fn remove_rolls(input: ParseResult) {
  let output =
    set.fold(input, input, fn(acc, key) {
      case count_adjecent(input, key) < 4 {
        True -> set.delete(acc, key)
        False -> acc
      }
    })
  #(output, set.size(input) - set.size(output))
}

fn count_adjecent(grid: ParseResult, position: #(Int, Int)) {
  list.count(offsets, fn(offset) {
    set.contains(grid, vec2.translate(position, offset))
  })
}

pub type ParseResult =
  set.Set(#(Int, Int))

pub fn parse(input: String) -> ParseResult {
  use acc, line, row_index <- list.index_fold(
    string.split(string.trim(input), "\n"),
    from: set.new(),
  )
  use acc, cell, column <- list.index_fold(string.split(line, ""), acc)
  case cell == "@" {
    False -> acc
    True -> set.insert(acc, #(row_index, column))
  }
}
