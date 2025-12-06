import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Range {
  Range(lower: Int, upper: Int)
}

type AvailableIngredientIds =
  set.Set(Int)

fn is_in_range(range: Range, x: Int) -> Bool {
  range.lower <= x && range.upper >= x
}

fn parse(content: String) -> #(List(Range), AvailableIngredientIds) {
  let lines = content |> string.split("\n")

  let #(fresh, available) =
    lines
    |> list.split_while(fn(line) { line != "" })

  let available = available |> list.rest() |> result.unwrap([])

  let fresh_ingredient_ranges =
    fresh
    |> list.fold(list.new(), fn(fresh_ingredient_ranges, f) {
      let assert [lower, upper] = f |> string.split("-")
      let lower = lower |> int.parse() |> result.unwrap(0)
      let upper = upper |> int.parse() |> result.unwrap(0)
      [Range(lower, upper), ..fresh_ingredient_ranges]
    })
    |> list.reverse()

  let available_ingredient_ids =
    available
    |> list.fold(set.new(), fn(available_ingredient_ids, a) {
      let a = a |> int.parse() |> result.unwrap(0)
      set.insert(available_ingredient_ids, a)
    })

  #(fresh_ingredient_ranges, available_ingredient_ids)
}

fn get_ingredients() -> #(List(Range), AvailableIngredientIds) {
  simplifile.read("./src/days/day05/input.txt")
  |> result.map(parse)
  |> result.unwrap(#(list.new(), set.new()))
}

pub fn part1() -> Result(Int, String) {
  let #(fresh_ranges, available) = get_ingredients()
  Ok(
    available
    |> set.filter(fn(a) {
      fresh_ranges
      |> list.any(fn(r) { is_in_range(r, a) })
    })
    |> set.size(),
  )
}

pub fn part2() -> Result(Int, String) {
  let #(fresh_ranges, _) = get_ingredients()

  let sorted_ranges =
    fresh_ranges |> list.sort(fn(r1, r2) { int.compare(r1.lower, r2.lower) })

  let reduced_ranges =
    sorted_ranges
    |> list.fold([], fn(acc, range) {
      case acc {
        [] -> [range]
        [last, ..rest] -> handle_overlap(range, last, acc, rest)
      }
    })

  let res =
    reduced_ranges
    |> list.fold(0, fn(acc, r) {
      let x = { r.upper - r.lower } + 1
      acc + x
    })

  Ok(res)
}

fn handle_overlap(
  range: Range,
  last: Range,
  acc: List(Range),
  rest: List(Range),
) -> List(Range) {
  case range.lower <= last.upper {
    True -> [Range(last.lower, int.max(last.upper, range.upper)), ..rest]
    False -> [range, ..acc]
  }
}
