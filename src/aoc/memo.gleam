import gleam/erlang/atom
import gleam/int

pub fn create(callback) {
  let cache = new()
  let result = callback(cache)
  ets_drop(cache)
  result
}

pub fn new() {
  let unique_name = "memo-" <> monotonic_time() |> int.to_string
  ets_new(atom.create(unique_name), [Set, Private])
}

pub fn memoize(cache: EtsTable(a, b), argument: a, callback: fn() -> b) -> b {
  case ets_lookup(cache, argument) {
    [#(_, x)] -> x
    [] -> {
      let x = callback()
      ets_insert(cache, #(argument, x))
      x
    }
    _ -> panic
  }
}

pub type EtsTable(a, b)

pub type EtsOption {
  Set
  Private
}

@external(erlang, "ets", "new")
fn ets_new(name: atom.Atom, opts: List(EtsOption)) -> EtsTable(a, b)

@external(erlang, "ets", "lookup")
fn ets_lookup(table: EtsTable(a, b), key: a) -> List(#(a, b))

@external(erlang, "ets", "insert")
fn ets_insert(table: EtsTable(a, b), input: #(a, b)) -> Bool

@external(erlang, "ets", "delete")
fn ets_drop(table: EtsTable(a, b)) -> Bool

@external(erlang, "erlang", "monotonic_time")
fn monotonic_time() -> Int
