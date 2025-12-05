import argv
import days/day01/day01
import days/day02/day02
import days/day03/day03
import days/day04/day04
import gleam/int
import gleam/io
import gleam/option
import lib/aoc_runner.{Day, Part, add_day, aoc, run_all_days, run_specific_day}

pub fn main() -> Nil {
  let day = case argv.load().arguments {
    [] -> option.None
    [day, ..] ->
      case int.parse(day) {
        Ok(day) -> option.Some(day)
        Error(_) -> {
          io.println("aoc2025: illegal day_number")
          io.println("usage: gleam run [day_number:int]")
          option.Some(-1)
        }
      }
  }

  let runner =
    aoc()
    |> add_day(Day(
      1,
      Part(1, day01.part1, option.Some(1177), []),
      Part(2, day01.part2, option.Some(6768), []),
    ))
    |> add_day(Day(
      2,
      Part(1, day02.part1, option.Some(44_487_518_055), []),
      Part(2, day02.part2, option.Some(53_481_866_137), []),
    ))
    |> add_day(Day(
      3,
      Part(1, day03.part1, option.Some(17_493), []),
      Part(2, day03.part2, option.Some(173_685_428_989_126), []),
    ))
    |> add_day(Day(
      4,
      Part(1, day04.part1, option.Some(1551), []),
      Part(2, day04.part2, option.Some(9784), []),
    ))

  case day {
    option.Some(day) if day > 0 -> run_specific_day(runner, day)
    option.None -> run_all_days(runner)
    _ -> Nil
  }
}
