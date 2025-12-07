import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Op {
  Add
  Mul
}

fn parse_ops(ops: String) -> List(Op) {
  ops
  |> string.split(" ")
  |> list.fold([], fn(acc, x) {
    case x {
      "+" -> [Add, ..acc]
      "*" -> [Mul, ..acc]
      _ -> acc
    }
  })
  |> list.reverse()
}

fn parse_numbers_part1(numbers: List(String)) -> List(List(Int)) {
  numbers
  |> list.fold([], fn(acc, row) {
    let cols =
      row
      |> string.split(" ")
      |> list.fold([], fn(acc, col) {
        case col {
          " " -> acc
          "" -> acc
          n -> [int.parse(n) |> result.unwrap(0), ..acc]
        }
      })
      |> list.reverse()
    [cols, ..acc]
  })
  |> list.transpose()
}

fn parse_part1(content: String) -> #(List(List(Int)), List(Op)) {
  let assert [ops, ..numbers] = content |> string.split("\n") |> list.reverse()
  let ops = parse_ops(ops)
  let numbers = parse_numbers_part1(numbers)
  #(numbers, ops)
}

fn get_part_1() -> #(List(List(Int)), List(Op)) {
  simplifile.read("./src/days/day06/input.txt")
  |> result.map(parse_part1)
  |> result.unwrap(#(list.new(), list.new()))
}

fn apply_ops(numbers: List(List(Int)), ops: List(Op), total: Int) -> Int {
  case numbers, ops {
    [head_numbers, ..rest_numbers], [head_op, ..rest_op] -> {
      let initial_acc = case head_op {
        Add -> 0
        Mul -> 1
      }
      let res =
        list.fold(head_numbers, initial_acc, fn(acc, x) {
          case head_op {
            Add -> acc + x
            Mul -> acc * x
          }
        })
      apply_ops(rest_numbers, rest_op, total + res)
    }
    _, _ -> total
  }
}

pub fn part1() -> Result(Int, String) {
  let #(numbers, ops) = get_part_1()
  let response = apply_ops(numbers, ops, 0)
  Ok(response)
}

fn strs_to_int(l: List(String)) -> Int {
  l
  |> list.filter(fn(x) { x != " " })
  |> string.concat()
  |> int.parse()
  |> result.unwrap(0)
}

fn vertical_grouping(
  l: List(List(String)),
  out: List(List(Int)),
) -> List(List(Int)) {
  case l {
    [] -> out
    [x, ..rest] -> {
      case x |> list.all(fn(x) { x == " " }) {
        True -> vertical_grouping(rest, [[], ..out])
        False -> {
          case out {
            [] -> vertical_grouping(rest, [[strs_to_int(x)]])
            [head, ..out_rest] ->
              vertical_grouping(rest, [[strs_to_int(x), ..head], ..out_rest])
          }
        }
      }
    }
  }
}

fn parse_numbers_part2(numbers: List(String)) -> List(List(Int)) {
  let rs = numbers |> list.map(fn(x) { x |> string.to_graphemes() })
  let zipped = list.transpose(rs)
  vertical_grouping(zipped, [])
}

fn parse_part2(content: String) -> #(List(List(Int)), List(Op)) {
  let assert [ops, ..numbers] = content |> string.split("\n") |> list.reverse()
  let ops = parse_ops(ops)
  let numbers = parse_numbers_part2(numbers |> list.reverse()) |> list.reverse()
  #(numbers, ops)
}

fn get_part_2() -> #(List(List(Int)), List(Op)) {
  simplifile.read("./src/days/day06/input.txt")
  |> result.map(parse_part2)
  |> result.unwrap(#(list.new(), list.new()))
}

pub fn part2() -> Result(Int, String) {
  let #(numbers, ops) = get_part_2()
  Ok(apply_ops(numbers, ops, 0))
}
