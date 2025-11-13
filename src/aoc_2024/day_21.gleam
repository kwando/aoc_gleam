import aoc/vec2.{type Vec2}
import gleam/result

pub type Numpad {
  Numpad(position: Vec2)
}

pub type NumpadButton {
  Digit(Int)
  Actuate
}

fn button_position(button: NumpadButton) {
  case button {
    Actuate -> #(2, 0)
    Digit(0) -> #(1, 0)

    Digit(1) -> #(0, 1)
    Digit(2) -> #(1, 1)
    Digit(3) -> #(2, 1)

    Digit(4) -> #(0, 2)
    Digit(5) -> #(1, 2)
    Digit(6) -> #(2, 2)

    Digit(7) -> #(0, 3)
    Digit(8) -> #(1, 3)
    Digit(9) -> #(2, 3)

    Digit(_) -> panic as "invalid button position"
  }
}

fn numpad_digit(position: Vec2) {
  case position {
    #(1, 0) -> Ok(Digit(0))
    #(2, 0) -> Ok(Actuate)

    #(0, 1) -> Ok(Digit(1))
    #(1, 1) -> Ok(Digit(2))
    #(2, 1) -> Ok(Digit(3))

    #(0, 2) -> Ok(Digit(4))
    #(1, 2) -> Ok(Digit(5))
    #(2, 2) -> Ok(Digit(6))

    #(0, 3) -> Ok(Digit(7))
    #(1, 3) -> Ok(Digit(8))
    #(2, 3) -> Ok(Digit(9))

    #(_, _) -> Error(Nil)
  }
}

pub fn pt_1(input: String) {
  let numpad =
    Numpad(position: #(1, 2))
    |> echo

  numpad.position
  |> numpad_digit
  |> echo
  |> result.map(button_position)
  |> echo
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
