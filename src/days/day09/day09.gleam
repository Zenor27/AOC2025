import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Coordinate {
  Coordinate(x: Int, y: Int, is_green: Bool)
}

type Rectangle {
  Rectangle(c1: Coordinate, c2: Coordinate, area: Int)
}

type Vertice {
  Vertice(c1: Coordinate, c2: Coordinate, horizontal: Bool)
}

fn parse(content: String) -> List(Coordinate) {
  content
  |> string.split("\n")
  |> list.map(fn(s) {
    let assert [x, y] = s |> string.split(",")
    Coordinate(
      x |> int.parse() |> result.unwrap(0),
      y |> int.parse() |> result.unwrap(0),
      False,
    )
  })
}

fn get_coordinates() -> List(Coordinate) {
  simplifile.read("./src/days/day09/example.txt")
  |> result.map(parse)
  |> result.unwrap([])
}

fn compute_area(c1: Coordinate, c2: Coordinate) -> Int {
  { int.absolute_value(c1.x - c2.x) + 1 }
  * { int.absolute_value(c1.y - c2.y) + 1 }
}

fn get_rectangles(coordinates: List(Coordinate)) -> List(Rectangle) {
  list.combination_pairs(coordinates)
  |> list.map(fn(c) {
    let #(c1, c2) = c
    Rectangle(c1, c2, compute_area(c1, c2))
  })
}

pub fn part1() -> Result(Int, String) {
  let coordinates = get_coordinates()
  let res =
    get_rectangles(coordinates)
    |> list.sort(fn(a, b) { int.compare(a.area, b.area) })
    |> list.reverse()
    |> list.first()
    |> result.map(fn(r) { r.area })
    |> result.map_error(fn(_) { "error" })
  res
}

type BoundingBox {
  BoundingBox(x_min: Int, x_max: Int, y_min: Int, y_max: Int)
}

fn get_bounding_box(coordinates: List(Coordinate)) -> BoundingBox {
  let xs = coordinates |> list.map(fn(c) { c.x }) |> list.sort(int.compare)
  let ys = coordinates |> list.map(fn(c) { c.y })

  BoundingBox(
    xs |> list.first() |> result.unwrap(0),
    xs |> list.last() |> result.unwrap(0),
    ys |> list.first() |> result.unwrap(0),
    ys |> list.last() |> result.unwrap(0),
  )
}

fn get_vertices(coordinates: List(Coordinate)) -> List(Vertice) {
  let grouped_horizontal = coordinates |> list.group(fn(c) { c.y })
  let grouped_vertical = coordinates |> list.group(fn(c) { c.x })

  let vertices =
    grouped_horizontal
    |> dict.fold([], fn(acc, _, v) {
      let assert [p1, p2] = v
      [Vertice(p1, p2, True), ..acc]
    })

  let vertices =
    grouped_vertical
    |> dict.fold([], fn(acc, _, v) {
      let assert [p1, p2] = v
      [Vertice(p1, p2, False), ..acc]
    })
    |> list.append(vertices)

  vertices
}

fn get_intersections(coordinates: List(Coordinate)) -> set.Set(Coordinate) {
  let bounding_box = get_bounding_box(coordinates)
  let vertices = get_vertices(coordinates)
  let vertices_coordinates =
    get_vertices_coordinates(vertices, []) |> set.from_list()

  let intersections =
    list.range(bounding_box.y_min, bounding_box.y_max)
    |> list.fold(set.new(), fn(acc, y) {
      do_get_intersections_x(
        y,
        bounding_box.x_min,
        bounding_box.x_max,
        vertices_coordinates,
        set.new(),
      )
      |> set.union(acc)
    })

  intersections
}

fn do_get_intersections_x(
  y: Int,
  x: Int,
  max_x: Int,
  vertices_coordinates: set.Set(Coordinate),
  green_tiles: set.Set(Coordinate),
) -> set.Set(Coordinate) {
  case x {
    _ if x > max_x -> green_tiles
    _ -> {
      let has_green = set.contains(vertices_coordinates, Coordinate(x, y, True))
      let has_red = set.contains(vertices_coordinates, Coordinate(x, y, False))
      case has_green || has_red {
        True if has_green -> {
          let new_green_tiles =
            green_tiles |> set.insert(Coordinate(x, y, True))
          do_get_intersections_x(
            y,
            x + 1,
            max_x,
            vertices_coordinates,
            new_green_tiles,
          )
        }
        True -> {
          let new_green_tiles =
            green_tiles |> set.insert(Coordinate(x, y, False))
          do_get_intersections_x(
            y,
            x + 1,
            max_x,
            vertices_coordinates,
            new_green_tiles,
          )
        }
        False ->
          do_get_intersections_x(
            y,
            x + 1,
            max_x,
            vertices_coordinates,
            green_tiles,
          )
      }
    }
  }
}

fn get_vertices_coordinates(
  vertices: List(Vertice),
  coordinates: List(Coordinate),
) -> List(Coordinate) {
  case vertices {
    [] -> coordinates
    [first, ..rest] -> {
      get_vertices_coordinates(
        rest,
        coordinates |> list.append(generate_coordinates_from_vertice(first)),
      )
    }
  }
}

fn generate_coordinates_from_vertice(v: Vertice) -> List(Coordinate) {
  case v.horizontal {
    True -> {
      let min_x = int.min(v.c1.x, v.c2.x)
      let max_x = int.max(v.c1.x, v.c2.x)
      list.range(min_x, max_x)
      |> list.map(fn(x) { Coordinate(x, v.c1.y, x != min_x && x != max_x) })
    }
    False -> {
      let min_y = int.min(v.c1.y, v.c2.y)
      let max_y = int.max(v.c1.y, v.c2.y)
      list.range(min_y, max_y)
      |> list.map(fn(y) { Coordinate(v.c1.x, y, y != min_y && y != max_y) })
    }
  }
}

fn get_green_tiles(intersections: set.Set(Coordinate)) -> List(Coordinate) {
  todo
}

pub fn part2() -> Result(Int, String) {
  let coordinates = get_coordinates()
  let intersections = get_intersections(coordinates)
  let x = intersections
  echo x
  // let green_tiles = get_green_tiles(intersections)

  Ok(1)
}
