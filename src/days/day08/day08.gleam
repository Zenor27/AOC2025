import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Coordinate {
  Coordinate(x: Int, y: Int, z: Int)
}

type Edge {
  Edge(c1: Coordinate, c2: Coordinate, dist: Float)
}

fn parse(content: String) -> List(Coordinate) {
  content
  |> string.split("\n")
  |> list.fold([], fn(acc, x) {
    let assert [x, y, z] =
      x
      |> string.split(",")
      |> list.map(fn(n) { int.parse(n) |> result.unwrap(0) })
    [Coordinate(x, y, z), ..acc]
  })
  |> list.reverse()
}

fn get_coordinates() -> List(Coordinate) {
  simplifile.read("./src/days/day08/input.txt")
  |> result.map(parse)
  |> result.unwrap([])
}

fn sld(c1: Coordinate, c2: Coordinate) -> Float {
  float.square_root(
    { int.power(c1.x - c2.x, 2.0) |> result.unwrap(0.0) }
    +. { int.power(c1.y - c2.y, 2.0) |> result.unwrap(0.0) }
    +. { int.power(c1.z - c2.z, 2.0) |> result.unwrap(0.0) },
  )
  |> result.unwrap(0.0)
}

fn get_edges(coordinates: List(Coordinate), edges: List(Edge)) -> List(Edge) {
  case coordinates {
    [] -> edges
    [first, ..rest] -> {
      let new_edges = list.map(rest, fn(e) { Edge(first, e, sld(first, e)) })

      get_edges(rest, list.append(new_edges, edges))
    }
  }
}

fn connect_edges(
  edges: List(Edge),
  connections: List(set.Set(Coordinate)),
) -> List(set.Set(Coordinate)) {
  case edges {
    [] -> connections
    [first, ..rest] -> {
      let c1_set =
        list.find(connections, fn(c) { set.contains(c, first.c1) })
        |> result.unwrap(set.new() |> set.insert(first.c1))
      let c2_set =
        list.find(connections, fn(c) { set.contains(c, first.c2) })
        |> result.unwrap(set.new() |> set.insert(first.c2))

      let new_connections = {
        [
          set.union(c1_set, c2_set),
          ..{ connections |> list.filter(fn(c) { c != c1_set && c != c2_set }) }
        ]
      }

      connect_edges(rest, new_connections)
    }
  }
}

fn connect_edges_part2(
  edges: List(Edge),
  connections: List(set.Set(Coordinate)),
  coordinates: #(Coordinate, Coordinate),
) -> #(Coordinate, Coordinate) {
  case edges {
    [] -> coordinates
    [first, ..rest] -> {
      let c1_set =
        list.find(connections, fn(c) { set.contains(c, first.c1) })
        |> result.unwrap(set.new() |> set.insert(first.c1))
      let c2_set =
        list.find(connections, fn(c) { set.contains(c, first.c2) })
        |> result.unwrap(set.new() |> set.insert(first.c2))

      let new_connections = {
        [
          set.union(c1_set, c2_set),
          ..{ connections |> list.filter(fn(c) { c != c1_set && c != c2_set }) }
        ]
      }

      case new_connections |> list.length() {
        1 -> #(first.c1, first.c2)
        _ -> connect_edges_part2(rest, new_connections, #(first.c1, first.c2))
      }
    }
  }
}

pub fn part1() -> Result(Int, String) {
  let coordinates = get_coordinates()
  let edges = get_edges(coordinates, [])

  let top_edges =
    edges
    |> list.sort(fn(e1, e2) { float.compare(e1.dist, e2.dist) })
    |> list.take(1000)

  let res =
    connect_edges(top_edges, [])
    |> list.map(fn(s) { set.size(s) })
    |> list.unique()
    |> list.sort(int.compare)
    |> list.reverse()
    |> list.take(3)
    |> list.fold(1, int.multiply)

  Ok(res)
}

pub fn part2() -> Result(Int, String) {
  let coordinates = get_coordinates()
  let edges = get_edges(coordinates, [])

  let top_edges =
    edges
    |> list.sort(fn(e1, e2) { float.compare(e1.dist, e2.dist) })

  let assert [first_coordinate, ..] = coordinates
  let connections =
    coordinates
    |> list.fold([], fn(acc, c) { [set.new() |> set.insert(c), ..acc] })

  let #(c1, c2) =
    connect_edges_part2(top_edges, connections, #(
      first_coordinate,
      first_coordinate,
    ))

  Ok(c1.x * c2.x)
}
