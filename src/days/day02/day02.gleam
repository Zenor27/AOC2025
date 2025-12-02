import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Range =
  #(Int, Int)

fn parse_file(content: String) -> List(Range) {
  content
  |> string.trim()
  |> string.split(on: ",")
  |> list.map(fn(range) {
    let assert [l, r] = range |> string.split(on: "-")
    let assert Ok(l_parsed) = int.parse(l)
    let assert Ok(r_parsed) = int.parse(r)
    #(l_parsed, r_parsed)
  })
}

fn get_ranges() -> List(Range) {
  simplifile.read("./src/days/day02/input.txt")
  |> result.map(parse_file)
  |> result.unwrap([])
}

fn get_chunks(s: String, chunk_size: Int) -> List(String) {
  s
  |> string.to_graphemes
  |> list.sized_chunk(into: chunk_size)
  |> list.map(string.concat)
}

fn is_invalid(s: String, chunk_size: Int) -> Bool {
  let chunks = get_chunks(s, chunk_size)
  chunks |> list.unique() |> list.length() == 1
}

pub fn part1() -> Result(Int, String) {
  let ranges = get_ranges()
  let res =
    ranges
    |> list.fold(0, fn(acc, range) {
      let #(lower_range, upper_range) = range

      let invalid_ids =
        list.range(lower_range, upper_range)
        |> list.filter(fn(id) {
          let id_str = int.to_string(id)
          let id_len = string.length(id_str)

          case id_len % 2 {
            0 -> is_invalid(id_str, id_len / 2)
            _ -> False
          }
        })

      acc + int.sum(invalid_ids)
    })

  Ok(res)
}

fn get_divisors(x: Int) -> List(Int) {
  list.range(2, x)
  |> list.filter(fn(n) { x % n == 0 })
}

pub fn part2() -> Result(Int, String) {
  let ranges = get_ranges()
  let res =
    ranges
    |> list.fold(0, fn(acc, range) {
      let #(lower_range, upper_range) = range

      let invalid_ids =
        list.range(lower_range, upper_range)
        |> list.filter(fn(id) {
          let id_str = int.to_string(id)
          let id_len = string.length(id_str)
          case id_len {
            1 -> False
            _ ->
              get_divisors(id_len)
              |> list.any(fn(d) { is_invalid(id_str, id_len / d) })
          }
        })

      acc + int.sum(invalid_ids)
    })

  Ok(res)
}
