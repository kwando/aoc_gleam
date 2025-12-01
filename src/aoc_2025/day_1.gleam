import aoc/utils.{iff}
import gleam/int
import gleam/list
import gleam/string

pub type Rotation {
  Left(Int)
  Right(Int)
}

pub fn pt_1(input: List(Int)) {
  count_zeroes(50, input, 0)
}

// WRONG 6769
pub fn pt_2(input: List(Int)) {
  list.fold(input, #(50, 0), fn(acc, rotation) {
    let #(position, zeros) = acc
    let new_pos = { position + int_mod(rotation, 100) } % 100
    let rotations = case rotation < 0 {
      True -> { 100 - position - rotation } / 100 - { 100 - position } / 100
      False -> { position + rotation } / 100
    }
    #(new_pos, zeros + rotations)
  }).1
}

fn count_zeroes(position, rotations, zeroes) {
  case rotations {
    [] -> zeroes
    [rotation, ..rest] -> {
      let new_pos = { position + int_mod(rotation, 100) } % 100
      count_zeroes(new_pos, rest, iff(new_pos == 0, zeroes + 1, zeroes))
    }
  }
}

pub fn parse(input: String) -> List(Int) {
  use value <- list.map(string.split(input, "\n"))
  case value {
    "L" <> rest -> -unsafe_int(rest)
    "R" <> rest -> unsafe_int(rest)
    _ -> panic as "bad rotation"
  }
}

fn unsafe_int(value) {
  let assert Ok(value) = int.parse(value)
  value
}

fn int_mod(value, mod) {
  let assert Ok(value) = int.modulo(value, mod)
  value
}
