import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Cell {
  Roll
  Empty
}

fn parse_matrix(
  content: String,
  marked: set.Set(#(Int, Int)),
) -> List(List(Cell)) {
  content
  |> string.split("\n")
  |> list.index_fold([], fn(rows, line, row) {
    list.append(rows, [
      line
      |> string.to_graphemes()
      |> list.index_fold([], fn(cols, c, col) {
        list.append(cols, [
          case c, marked |> set.contains(#(row, col)) {
            _, True -> Empty
            ".", _ -> Empty
            _, _ -> Roll
          },
        ])
      }),
    ])
  })
}

fn get_matrix(marked: set.Set(#(Int, Int))) -> List(List(Cell)) {
  simplifile.read("./src/days/day04/input.txt")
  |> result.map(fn(x) { parse_matrix(x, marked) })
  |> result.unwrap([])
}

fn list_at(l: List(a), i: Int) -> option.Option(a) {
  case l, i {
    [first, ..], _ if i == 0 -> option.Some(first)
    [_, ..rest], _ -> list_at(rest, i - 1)
    _, _ -> option.None
  }
}

fn mat_at(mat: List(List(a)), i: Int, j: Int) -> option.Option(a) {
  list_at(mat, i) |> option.map(fn(r) { list_at(r, j) }) |> option.flatten()
}

fn get_is_accessible(mat: List(List(Cell)), i: Int, j: Int) -> Bool {
  let lt = mat_at(mat, i - 1, j - 1)
  let t = mat_at(mat, i - 1, j)
  let rt = mat_at(mat, i - 1, j + 1)
  let l = mat_at(mat, i, j - 1)
  let r = mat_at(mat, i, j + 1)
  let lb = mat_at(mat, i + 1, j - 1)
  let b = mat_at(mat, i + 1, j)
  let rb = mat_at(mat, i + 1, j + 1)
  let adjacent_rolls =
    [lt, t, rt, l, r, lb, b, rb]
    |> list.filter(fn(cell) {
      case cell {
        option.Some(Roll) -> True
        _ -> False
      }
    })
  { adjacent_rolls |> list.length() } < 4
}

pub fn part1() -> Result(Int, String) {
  let mat = get_matrix(set.new())
  let rows = mat |> list.length()
  let cols = mat |> list.first() |> result.map(list.length) |> result.unwrap(0)

  let res =
    list.range(0, rows - 1)
    |> list.fold(0, fn(accessible_rolls, i) {
      let accessible_rolls_in_row =
        list.range(0, cols - 1)
        |> list.fold(0, fn(acc, j) {
          case mat_at(mat, i, j) {
            option.Some(Empty) -> acc
            _ ->
              case get_is_accessible(mat, i, j) {
                True -> {
                  acc + 1
                }
                False -> acc
              }
          }
        })
      accessible_rolls_in_row + accessible_rolls
    })

  Ok(res)
}

fn solve_part2(
  mat: List(List(Cell)),
  rows: Int,
  cols: Int,
  marked: set.Set(#(Int, Int)),
  accessible: Int,
) -> Int {
  let marked_len = marked |> set.size()

  let #(new_accessible, new_marked) =
    list.range(0, rows - 1)
    |> list.fold(#(0, marked), fn(state, i) {
      let #(accessible_rolls, marked) = state

      let #(accessible_rolls_in_row, new_marked) =
        list.range(0, cols - 1)
        |> list.fold(#(0, marked), fn(acc, j) {
          let #(accessible_rolls_in_row, marked) = acc

          case mat_at(mat, i, j) {
            option.Some(Empty) -> acc
            _ ->
              case get_is_accessible(mat, i, j) {
                True -> {
                  #(accessible_rolls_in_row + 1, marked |> set.insert(#(i, j)))
                }
                False -> acc
              }
          }
        })
      #(
        accessible_rolls_in_row + accessible_rolls,
        set.union(marked, new_marked),
      )
    })

  case set.size(new_marked) == marked_len {
    True -> accessible
    _ ->
      solve_part2(
        get_matrix(new_marked),
        rows,
        cols,
        new_marked,
        accessible + new_accessible,
      )
  }
}

pub fn part2() -> Result(Int, String) {
  let mat = get_matrix(set.new())
  let rows = mat |> list.length()
  let cols = mat |> list.first() |> result.map(list.length) |> result.unwrap(0)

  Ok(solve_part2(mat, rows, cols, set.new(), 0))
}
