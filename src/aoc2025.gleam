import argv
import days/day01/day01
import days/day02/day02
import days/day03/day03
import days/day04/day04
import days/day05/day05
import days/day06/day06
import days/day07/day07
import days/day08/day08
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
    |> add_day(Day(
      5,
      Part(1, day05.part1, option.Some(520), []),
      Part(2, day05.part2, option.Some(347_338_785_050_515), []),
    ))
    |> add_day(Day(
      6,
      Part(1, day06.part1, option.Some(6_605_396_225_322), []),
      Part(2, day06.part2, option.Some(11_052_310_600_986), []),
    ))
    |> add_day(Day(
      7,
      Part(1, day07.part1, option.Some(1622), []),
      Part(2, day07.part2, option.Some(10_357_305_916_520), [
        4_490_344_914_870_299_010_415_820_639_255_910_178_233_809_201_952_429_950_141_014,
      ]),
    ))
    |> add_day(Day(
      8,
      Part(1, day08.part1, option.Some(127_551), [
        131_141_037_065_430_712_320_000_000,
        1040,
      ]),
      Part(2, day08.part2, option.Some(2_347_225_200), []),
    ))

  case day {
    option.Some(day) if day > 0 -> run_specific_day(runner, day)
    option.None -> run_all_days(runner)
    _ -> Nil
  }
}
