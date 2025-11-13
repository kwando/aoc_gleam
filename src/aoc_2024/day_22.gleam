import gleam/dict
import gleam/int.{bitwise_exclusive_or as mix}
import gleam/list
import gleam/option
import gleam/string

pub fn pt_1(buyers: List(Int)) {
  use sum, secret <- list.fold(buyers, 0)
  sum + nth_secret(secret, 2000)
}

pub fn pt_2(buyers: List(Int)) {
  let buyers = [1, 2, 3, 2024]
}

fn sell_prices(
  secret,
  n: Int,
  current_price: Int,
  sequence: option.Option(#(Int, Int, Int, Int)),
  result: dict.Dict(#(Int, Int, Int, Int), Int),
) {
  todo
}

fn max_sellprice(
  buyers: List(Int),
  sequences: List(List(Int)),
) -> #(Int, List(Int)) {
  use current_max, seq <- list.fold(sequences, #(0, []))
  let acc_price =
    list.fold(buyers, 0, fn(sum, initial_secret) {
      case sell_price(initial_secret, 2000, seq) {
        Ok(price) -> sum + price
        Error(_) -> sum
      }
    })
  case acc_price > current_max.0 {
    True -> #(acc_price, seq)
    False -> current_max
  }
}

fn every_sequence(state: a, callback: fn(a, List(Int)) -> a) -> a {
  let sequence = [-9, -9, -9, -9]
  every_sequence_loop(callback, sequence, state)
}

fn every_sequence_loop(callback: fn(a, List(Int)) -> a, seq, state: a) {
  let new_state = callback(state, seq)
  case next_sequence(seq) {
    Error(_) -> state
    Ok(next_seq) -> {
      every_sequence_loop(callback, next_seq, new_state)
    }
  }
}

fn next_sequence(sequence: List(Int)) {
  case sequence {
    [9, 9, 9, 9] -> Error(Nil)
    [a, 9, 9, 9] -> [a + 1, -9, -9, -9] |> Ok
    [a, b, 9, 9] -> [a, b + 1, -9, -9] |> Ok
    [a, b, c, 9] -> [a, b, c + 1, -9] |> Ok
    [a, b, c, d] -> [a, b, c, d + 1] |> Ok
    _ -> Error(Nil)
  }
}

fn increment(x) {
  case x > 9 {
    True -> Error(Nil)
    False -> Ok(x + 1)
  }
}

fn to_sequence(value) {
  [value / 1000, { value / 100 } % 10, { value / 10 } % 10, value % 10]
}

fn sell_price(secret, iterations, seq) {
  sell_price_loop(secret, iterations - 1, secret_price(secret), seq, seq)
}

fn sell_price_loop(
  secret,
  n: Int,
  current_price: Int,
  sequence: List(Int),
  full_sequence: List(Int),
) {
  case n, sequence {
    0, _ -> Error(Nil)
    _, [] -> Ok(current_price)
    n, [seq, ..next] -> {
      let secret = next_secret(secret)
      let price = secret_price(secret)
      let delta = price - current_price

      case delta == seq {
        True -> sell_price_loop(secret, n - 1, price, next, full_sequence)
        False ->
          sell_price_loop(secret, n - 1, price, full_sequence, full_sequence)
      }
    }
  }
}

pub fn prices(secret, n: Int, result: List(Int)) {
  case n {
    0 -> list.reverse(result)
    _ -> prices(next_secret(secret), n - 1, [secret_price(secret), ..result])
  }
}

fn secret_price(secret: Int) {
  let assert Ok(price) = int.modulo(secret, 10)
  price
}

fn nth_secret(secret: Int, n: Int) {
  case n {
    0 -> secret
    n if n < 0 -> panic
    _ -> nth_secret(next_secret(secret), n - 1)
  }
}

fn prune(res) {
  let assert Ok(res) = int.modulo(res, 16_777_216)
  res
}

fn next_secret(secret: Int) -> Int {
  let secret = mix(secret, secret * 64) |> prune
  let secret = mix(secret, secret / 32) |> prune
  mix(secret, secret * 2048) |> prune
}

pub fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    let assert Ok(x) = int.parse(x)
    x
  })
}
