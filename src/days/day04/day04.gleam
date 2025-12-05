import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Position =
  #(Int, Int)

fn parse(content: String) -> set.Set(Position) {
  content
  |> string.split("\n")
  |> list.index_fold(set.new(), fn(grid, line, row) {
    line
    |> string.to_graphemes()
    |> list.index_fold(grid, fn(inner_grid, char, col) {
      case char {
        "." -> inner_grid
        _ -> set.insert(inner_grid, #(row, col))
      }
    })
  })
}

fn get_positions() -> set.Set(Position) {
  simplifile.read("./src/days/day04/input.txt")
  |> result.map(parse)
  |> result.unwrap(set.new())
}

fn get_is_accessible(position: Position, positions: set.Set(Position)) -> Bool {
  let #(r, c) = position

  [
    #(r - 1, c - 1),
    #(r - 1, c),
    #(r - 1, c + 1),
    #(r, c - 1),
    #(r, c + 1),
    #(r + 1, c - 1),
    #(r + 1, c),
    #(r + 1, c + 1),
  ]
  |> list.count(fn(neighbor) { set.contains(positions, neighbor) })
  < 4
}

pub fn part1() -> Result(Int, String) {
  let positions = get_positions()
  Ok(
    positions
    |> set.filter(fn(position) { get_is_accessible(position, positions) })
    |> set.size(),
  )
}

fn solve_part2(positions: set.Set(Position), accessible: Int) -> Int {
  let to_remove =
    positions
    |> set.filter(fn(position) { get_is_accessible(position, positions) })

  let to_remove_size = to_remove |> set.size()

  case to_remove_size {
    0 -> accessible
    _ -> {
      let new_positions =
        to_remove
        |> set.fold(positions, fn(new_positions, element_to_remove) {
          new_positions |> set.delete(element_to_remove)
        })
      solve_part2(new_positions, accessible + to_remove_size)
    }
  }
}

pub fn part2() -> Result(Int, String) {
  let positions = get_positions()
  Ok(solve_part2(positions, 0))
}
