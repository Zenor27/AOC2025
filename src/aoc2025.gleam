import argv
import days/day01/day01
import gleam/dict
import gleam/int
import gleam/io
import gleam/result

pub fn get_days() {
  dict.from_list([
    #("day01", #(day01.part1, day01.part2)),
  ])
}

pub fn main() -> Nil {
  let assert [day_arg, ..] = argv.load().arguments

  let days = get_days()
  let maybe_day =
    dict.get(days, day_arg)
    |> result.replace_error("Day does not exists")

  case maybe_day {
    Ok(day) -> {
      let #(part1, part2) = day
      case part1() {
        Ok(res) -> io.println(day_arg <> " | PART1: " <> int.to_string(res))
        Error(err) -> io.println("An error occurred " <> err)
      }

      case part2() {
        Ok(res) -> io.println(day_arg <> " | PART2: " <> int.to_string(res))
        Error(err) -> io.println("An error occurred " <> err)
      }
    }
    Error(e) -> io.println(e)
  }
}
