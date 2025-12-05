import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/time/duration
import gleam/time/timestamp

pub type Part {
  Part(
    part_id: Int,
    part_fn: fn() -> Result(Int, String),
    expected: Option(Int),
    wrong_answers: List(Int),
  )
}

pub type Day {
  Day(day: Int, part1: Part, part2: Part)
}

pub type Runner {
  Runner(days: Dict(Int, Day))
}

type Report {
  Report(
    day: Day,
    part: Part,
    result: Result(Int, String),
    duration: duration.Duration,
  )
}

pub fn aoc() -> Runner {
  Runner(days: dict.new())
}

pub fn add_day(runner: Runner, day: Day) -> Runner {
  Runner(runner.days |> dict.insert(day.day, day))
}

pub fn run_all_days(runner: Runner) -> Nil {
  let total_days = {
    runner.days |> dict.size()
  }
  let subject = process.new_subject()
  runner.days
  |> dict.each(fn(_, day) {
    process.spawn(fn() { run_day(runner, day.day, subject) })
  })
  report_loop(subject, dict.new(), total_days)
}

pub fn run_specific_day(runner: Runner, day: Int) -> Nil {
  let subject = process.new_subject()
  run_day(runner, day, subject)
  report_loop(subject, dict.new(), 1)
}

fn run_part(day: Day, part: Part, subject: process.Subject(Report)) -> Nil {
  process.spawn(fn() {
    let start = timestamp.system_time()
    let result = part.part_fn()
    let end = timestamp.system_time()
    let diff = timestamp.difference(start, end)
    process.send(subject, Report(day, part, result, diff))
  })
  Nil
}

fn run_day(runner: Runner, day: Int, subject: process.Subject(Report)) -> Nil {
  case runner.days |> dict.get(day) {
    Ok(day) -> {
      io.println("🚀 Computing day " <> int.to_string(day.day))
      run_part(day, day.part1, subject)
      run_part(day, day.part2, subject)
    }
    Error(_) -> {
      io.println_error("Day " <> int.to_string(day) <> " does not exist!")
      panic
    }
  }
}

fn report_loop(
  subject: process.Subject(Report),
  completed: Dict(#(Int, Int), Report),
  total_days: Int,
) -> Nil {
  case completed |> dict.keys() |> list.length() == total_days * 2 {
    True -> {
      completed
      |> dict.keys()
      |> list.map(fn(k) {
        let #(d, _) = k
        d
      })
      |> list.unique()
      |> list.each(fn(d) {
        let assert Ok(report_part1) = completed |> dict.get(#(d, 1))
        let assert Ok(report_part2) = completed |> dict.get(#(d, 2))
        print_part_report(report_part1)
        print_part_report(report_part2)
      })
    }
    _ -> {
      let report = process.receive_forever(subject)
      io.println(
        "ℹ️ Day "
        <> int.to_string(report.day.day)
        <> " part "
        <> int.to_string(report.part.part_id)
        <> " finished!",
      )
      let completed =
        dict.insert(completed, #(report.day.day, report.part.part_id), report)
      report_loop(subject, completed, total_days)
    }
  }
}

fn print_part_report(report: Report) -> Nil {
  io.println(
    "➡️ Day "
    <> int.to_string(report.day.day)
    <> " Part "
    <> int.to_string(report.part.part_id)
    <> " result:",
  )
  case report.result {
    Ok(res) -> {
      let is_wrong_answer = list.contains(report.part.wrong_answers, res)
      case report.part.expected, is_wrong_answer {
        _, True ->
          io.println_error(
            "  ❌ Got " <> int.to_string(res) <> " which is incorrect...",
          )
        option.Some(expected), _ if expected != res ->
          io.println_error(
            "  ❌ Got "
            <> int.to_string(res)
            <> " but expected "
            <> int.to_string(expected),
          )
        option.Some(_), _ -> {
          io.println("  ✅ Got " <> int.to_string(res) <> " which is correct!")
        }
        _, _ -> {
          io.println("  🤷 Got " <> int.to_string(res))
        }
      }
    }
    Error(err) -> {
      io.println_error("  ❌ An error occurred while running part: " <> err)
    }
  }
  let duration_s = report.duration |> duration.to_seconds()
  io.println(
    "  ⏳ Took "
    <> duration_s |> float.to_precision(2) |> float.to_string()
    <> "s",
  )
}
