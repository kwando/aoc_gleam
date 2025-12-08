import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Coord =
  #(Int, Int, Int)

pub fn pt_1(input: String) {
  let coordinates = parse(input)

  list.combination_pairs(coordinates)
  |> list.sort(fn(left, right) {
    int.compare(
      distance_squared(left.0, left.1),
      distance_squared(right.0, right.1),
    )
  })
  |> list.take(1000)
  |> list.fold(setup_state(coordinates), connect)
  |> fn(x) {
    x.circuits
    |> dict.values
    |> list.map(set.size)
    |> list.sort(int.compare)
    |> list.reverse
    |> list.take(3)
    |> list.fold(1, int.multiply)
  }
}

fn distance_squared(a: #(Int, Int, Int), b: #(Int, Int, Int)) {
  { a.0 - b.0 }
  * { a.0 - b.0 }
  + { a.1 - b.1 }
  * { a.1 - b.1 }
  + { a.2 - b.2 }
  * { a.2 - b.2 }
}

pub type State {
  State(
    used_pairs: List(#(Coord, Coord)),
    lut: Dict(Coord, Int),
    circuits: Dict(Int, Set(Coord)),
  )
}

pub fn pt_2(input: String) {
  let coordinates = parse(input)

  list.fold_until(
    list.sort(list.combination_pairs(coordinates), fn(left, right) {
      int.compare(
        distance_squared(left.0, left.1),
        distance_squared(right.0, right.1),
      )
    }),
    setup_state(coordinates),
    fn(state, pair) {
      let updated_state = connect(state, pair)
      case dict.size(updated_state.circuits) {
        1 -> list.Stop(updated_state)
        _ -> list.Continue(updated_state)
      }
    },
  )
  |> fn(x) {
    let assert [#(#(x1, _, _), #(x2, _, _)), ..] = x.used_pairs
    x1 * x2
  }
}

fn setup_state(coordinates: List(Coord)) {
  State(
    used_pairs: [],
    lut: coordinates
      |> list.index_map(fn(coord, index) { #(coord, index) })
      |> dict.from_list,
    circuits: coordinates
      |> list.index_map(fn(coord, index) { #(index, set.from_list([coord])) })
      |> dict.from_list,
  )
}

fn connect(state: State, pair: #(Coord, Coord)) {
  case dict.get(state.lut, pair.0), dict.get(state.lut, pair.1) {
    Ok(a), Ok(b) if a == b ->
      State(..state, used_pairs: [pair, ..state.used_pairs])
    Ok(a), Ok(b) -> {
      let assert Ok(left) = dict.get(state.circuits, a)
      let assert Ok(right) = dict.get(state.circuits, b)

      State(
        lut: set.fold(right, state.lut, fn(lut, coord) {
          dict.insert(lut, coord, a)
        }),
        circuits: state.circuits
          |> dict.delete(b)
          |> dict.insert(a, set.union(left, right)),
        used_pairs: [pair, ..state.used_pairs],
      )
    }
    _, _ -> panic
  }
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    let assert Ok([a, b, c]) =
      x
      |> string.split(",")
      |> list.try_map(int.parse)

    #(a, b, c)
  })
}
