import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Bank =
  List(Int)

fn parse_banks(content: String) -> List(Bank) {
  content
  |> string.split("\n")
  |> list.map(fn(bank) {
    bank
    |> string.to_graphemes()
    |> list.map(fn(battery) { battery |> int.parse() |> result.unwrap(0) })
  })
}

fn get_banks() -> List(Bank) {
  simplifile.read("./src/days/day03/input.txt")
  |> result.map(parse_banks)
  |> result.unwrap([])
}

pub fn part1() -> Result(Int, String) {
  let res =
    get_banks()
    |> list.map(fn(l) { list.combination_pairs(l) })
    |> list.fold(0, fn(acc, bank_combinations) {
      let max_in_bank =
        bank_combinations
        |> list.max(fn(combination_a, combination_b) {
          let #(l_a, r_a) = combination_a
          let #(l_b, r_b) = combination_b
          int.compare(l_a * 10 + r_a, l_b * 10 + r_b)
        })
        |> result.map(fn(max) {
          let #(l, r) = max
          l * 10 + r
        })
        |> result.unwrap(0)

      acc + max_in_bank
    })

  Ok(res)
}

// Deprecated so I vendored it...
fn undigits(numbers: List(Int), base: Int) -> Result(Int, Nil) {
  case base < 2 {
    True -> Error(Nil)
    False -> undigits_loop(numbers, base, 0)
  }
}

fn undigits_loop(numbers: List(Int), base: Int, acc: Int) -> Result(Int, Nil) {
  case numbers {
    [] -> Ok(acc)
    [digit, ..] if digit >= base -> Error(Nil)
    [digit, ..rest] -> undigits_loop(rest, base, acc * base + digit)
  }
}

fn largest_subsequence(digits: List(Int), keep: Int) -> List(Int) {
  let drops_allowed = list.length(digits) - keep

  case drops_allowed < 0 {
    True -> []
    False -> {
      do_find_max(digits, [], drops_allowed)
      |> list.reverse
      |> list.take(keep)
    }
  }
}

fn do_find_max(remaining: List(Int), stack: List(Int), drops: Int) -> List(Int) {
  case remaining {
    [] -> stack
    [head, ..tail] -> {
      let #(new_stack, new_drops) = pop_smaller(stack, head, drops)
      do_find_max(tail, [head, ..new_stack], new_drops)
    }
  }
}

fn pop_smaller(stack: List(Int), current: Int, drops: Int) -> #(List(Int), Int) {
  case stack, drops > 0 {
    [top, ..rest], True if top < current ->
      pop_smaller(rest, current, drops - 1)
    _, _ -> #(stack, drops)
  }
}

pub fn part2() -> Result(Int, String) {
  let res =
    get_banks()
    |> list.map(fn(l) { largest_subsequence(l, 12) })
    |> list.fold(0, fn(acc, bank_combinations) {
      let max_in_bank =
        bank_combinations
        |> undigits(10)
        |> result.unwrap(0)

      acc + max_in_bank
    })

  Ok(res)
}
