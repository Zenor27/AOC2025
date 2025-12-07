import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Position {
  Position(x: Int, y: Int)
}

fn parse(content: String) -> set.Set(Position) {
  let rows = content |> string.split("\n")
  rows
  |> list.index_fold(set.new(), fn(acc, row, y) {
    row
    |> string.to_graphemes()
    |> list.index_fold(set.new(), fn(acc, item, x) {
      case item {
        "^" -> acc |> set.insert(Position(x, y))
        _ -> acc
      }
    })
    |> set.union(acc)
  })
}

fn get_splitter_positions() -> set.Set(Position) {
  simplifile.read("./src/days/day07/example.txt")
  |> result.map(parse)
  |> result.unwrap(set.new())
}

fn get_starting_position() -> Position {
  simplifile.read("./src/days/day07/example.txt")
  |> result.map(fn(content) {
    let x =
      content
      |> string.split("\n")
      |> list.first()
      |> result.unwrap("")
      |> string.to_graphemes()
      |> list.index_fold(0, fn(acc, x, i) {
        case x {
          "S" -> i
          _ -> acc
        }
      })
    Position(x, 0)
  })
  |> result.unwrap(Position(0, 0))
}

fn resolve_part1(
  splitters: List(Position),
  current_position: Position,
  marked: set.Set(Position),
) -> #(set.Set(Position), set.Set(Position)) {
  case marked |> set.contains(current_position) {
    True -> #(set.new(), marked)
    False -> {
      let intersecting =
        list.find(splitters, fn(s) {
          s.x == current_position.x && s.y > current_position.y
        })

      case intersecting {
        Ok(intersecting) -> {
          let new_marked = marked |> set.insert(current_position)
          let #(l, l_marked) =
            resolve_part1(
              splitters,
              Position(intersecting.x - 1, intersecting.y),
              new_marked,
            )
          let #(r, r_marked) =
            resolve_part1(
              splitters,
              Position(intersecting.x + 1, intersecting.y),
              new_marked |> set.union(l_marked),
            )
          #(
            l
              |> set.union(r)
              |> set.insert(intersecting),
            r_marked,
          )
        }
        Error(_) -> #(set.new(), marked)
      }
    }
  }
}

pub fn part1() -> Result(Int, String) {
  let splitters =
    get_splitter_positions()
    |> set.to_list()
    |> list.sort(fn(a, b) { int.compare(a.y, b.y) })
  let start = get_starting_position()
  let #(res, _) = resolve_part1(splitters, start, set.new())
  Ok(res |> set.size())
}

fn resolve_part2(
  splitters: List(Position),
  current_position: Position,
  visited: dict.Dict(Position, Int),
) -> #(Int, dict.Dict(Position, Int)) {
  case visited |> dict.has_key(current_position) {
    True -> #(
      visited |> dict.get(current_position) |> result.unwrap(0),
      visited,
    )
    False -> {
      let intersecting =
        list.find(splitters, fn(s) {
          s.x == current_position.x && s.y > current_position.y
        })

      case intersecting {
        Ok(intersecting) -> {
          let #(l, l_visited) =
            resolve_part2(
              splitters,
              Position(intersecting.x - 1, intersecting.y),
              visited,
            )
          let #(r, r_visited) =
            resolve_part2(
              splitters,
              Position(intersecting.x + 1, intersecting.y),
              l_visited,
            )
          #(l + r, r_visited |> dict.insert(current_position, l + r))
        }
        Error(_) -> #(1, visited |> dict.insert(current_position, 1))
      }
    }
  }
}

pub fn part2() -> Result(Int, String) {
  let splitters =
    get_splitter_positions()
    |> set.to_list()
    |> list.sort(fn(a, b) { int.compare(a.y, b.y) })
  let start = get_starting_position()
  let #(res, _) = resolve_part2(splitters, start, dict.new())
  Ok(res)
}
