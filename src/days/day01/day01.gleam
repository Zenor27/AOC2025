import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Direction {
  Left
  Right
}

const start_position = 50

const max_position = 100

fn parse_file(content: String) -> List(#(Direction, Int)) {
  content
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(s) {
    case s {
      "L" <> n -> #(Left, int.parse(n) |> result.unwrap(0))
      "R" <> n -> #(Right, int.parse(n) |> result.unwrap(0))
      _ -> panic
    }
  })
}

fn get_rotations() -> Result(List(#(Direction, Int)), String) {
  simplifile.read("./src/days/day01/input.txt")
  |> result.map(parse_file)
  |> result.replace_error("Could not read file")
}

pub fn part1() -> Result(Int, String) {
  use rotations <- result.try(get_rotations())
  let #(_, zero_count) =
    rotations
    |> list.fold(#(start_position, 0), fn(acc, r) {
      let #(prev_point, prev_zero_count) = acc
      let #(dir, rotation) = r
      let new_point = case dir {
        Left -> { prev_point - rotation } % max_position
        Right -> { prev_point + rotation } % max_position
      }
      case new_point {
        0 -> #(new_point, prev_zero_count + 1)
        _ -> #(new_point, prev_zero_count)
      }
    })
  Ok(zero_count)
}

pub fn part2() -> Result(Int, String) {
  use rotations <- result.try(get_rotations())
  let #(_, zero_count) =
    rotations
    |> list.fold(#(start_position, 0), fn(acc, r) {
      let #(prev_point, prev_zero_count) = acc
      let #(dir, rotation) = r

      case dir {
        Left -> {
          let dist_to_first_zero = case prev_point {
            0 -> max_position
            _ -> prev_point
          }

          let zero_count = case rotation >= dist_to_first_zero {
            True -> 1 + { rotation - dist_to_first_zero } / max_position
            False -> 0
          }

          let new_point = { prev_point - rotation } % max_position
          case new_point < 0 {
            True -> #(new_point + max_position, prev_zero_count + zero_count)
            False -> #(new_point, prev_zero_count + zero_count)
          }
        }
        Right -> {
          let zero_count = { prev_point + rotation } / max_position
          #(
            { prev_point + rotation } % max_position,
            prev_zero_count + zero_count,
          )
        }
      }
    })

  Ok(zero_count)
}
