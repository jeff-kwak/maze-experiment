class_name Maze
extends Object

enum Wall {
   North = 0x8, # Has a N wall
   South = 0x4, # Has a S wall
   East = 0x2, # Has an E wall
   West = 0x1 # Has a W wall
}


enum Data {
    Visited = 0x20 # Marked as completed by some algorithm
}


const BLOCKED_ROOM = Wall.North | Wall.South | Wall.East | Wall.West
const OPEN_ROOM = 0x0
const WALL_MASK = 0x0F # When used with bitwise and, discards all but the wall bits
const NO_CELL = Vector2i(-1, -1)


var grid_width: int
var grid_height: int
var grid: PackedInt32Array
var distances: PackedInt32Array
var entrance: Vector2i
var exit: Vector2i


var _rng: RandomNumberGenerator


func _init(width: int, height: int) -> void:
    grid_width = width
    grid_height = height
    _rng = RandomNumberGenerator.new()
    reset()


func reset() -> Maze:
    grid = PackedInt32Array()
    grid.resize(grid_width * grid_height)
    grid.fill(BLOCKED_ROOM)
    distances.resize(grid_width * grid_height)
    entrance = Vector2i.ZERO
    exit = Vector2i.ZERO
    return self


func grid_at(coord: Vector2i) -> int:
    return grid[coord.y * grid_width + coord.x]


func dist_at(coord: Vector2i) -> int:
    return distances[coord.y * grid_width + coord.x]


func is_visited(coord: Vector2i) -> bool:
    var result: int = grid_at(coord) & Data.Visited
    return result != 0


func random_square() -> Vector2i:
    var x: int = _rng.randi_range(0, grid_width - 1)
    var y: int = _rng.randi_range(0, grid_height - 1)
    return Vector2i(x, y)


func recursive_back_tracker(random_seed: int = 0) -> Maze:
    # Every algorithm will use its own rng
    _rng.seed = random_seed
    print("recursive back tracker: seed %s" % _rng.seed)

    # Pick a random square in the graph
    var init_square = random_square()

    # Initialize the stack and the starting cell
    var stack = Array()
    var cell: Vector2i = init_square

    # process the stack
    while cell != NO_CELL:
        _mark_visited(cell)

        var neighbors: Array = _neighbors_of(cell)
        var unvisited: Array = neighbors.filter(func(n): return not is_visited(n))

        if unvisited.size() > 0:
            var chosen = _pick(unvisited)
            _link_cells(cell, chosen)
            stack.push_back(chosen)
            cell = chosen
        else:
            cell = stack.pop_back() if stack.size() > 0 else NO_CELL

    _calc_distances()

    return self

func north_of(n: Vector2i) -> Vector2i:
    if n.y - 1 < 0:
        return NO_CELL

    return Vector2i(n.x, n.y - 1)

func south_of(n: Vector2i) -> Vector2i:
    if n.y + 1 >= grid_height:
        return NO_CELL

    return Vector2i(n.x, n.y + 1)

func east_of(n: Vector2i) -> Vector2i:
    if n.x - 1 < 0:
        return NO_CELL

    return Vector2i(n.x - 1, n.y)

func west_of(n: Vector2i) -> Vector2i:
    if n.x + 1 >= grid_width:
        return NO_CELL

    return Vector2i(n.x + 1, n.y)

func _neighbors_of(n: Vector2i) -> Array:
    var result: Array = [
        north_of(n),
        south_of(n),
        east_of(n),
        west_of(n)
    ].filter(func(c): return c != NO_CELL)
    return result

func _set_grid_at(coord: Vector2i, data: int) -> void:
    grid[coord.y * grid_width + coord.x] = data



func _set_dist_at(coord: Vector2i, data: int) -> void:
    distances[coord.y * grid_width + coord.x] = data


func _mark_visited(coord: Vector2i) -> void:
    var dt = grid_at(coord) | Data.Visited
    _set_grid_at(coord, dt)

func _pick(choices: Array):
    # The RNG is specific to this instance not global
    return choices[_rng.randi_range(0, choices.size() - 1)]

func _link_cells(a: Vector2i, b: Vector2i) -> void:
    var dir: Vector2i = b - a # position determines the direction they're linked
    if dir.x == 1:
        _set_grid_at(a, grid_at(a) & ~Wall.East)
        _set_grid_at(b, grid_at(b) & ~Wall.West)
    elif dir.x == -1:
        _set_grid_at(a, grid_at(a) & ~Wall.West)
        _set_grid_at(b, grid_at(b) & ~Wall.East)
    elif dir.y == 1:
        _set_grid_at(a, grid_at(a) & ~Wall.South)
        _set_grid_at(b, grid_at(b) & ~Wall.North)
    elif dir.y == -1:
        _set_grid_at(a, grid_at(a) & ~Wall.North)
        _set_grid_at(b, grid_at(b) & ~Wall.South)

func _is_linked(a: Vector2i, b: Vector2i) -> bool:
    var dir: Vector2i = b - a
    if dir.x == 1:
        return grid_at(a) & Wall.East != 0
    elif dir.x == -1:
        return grid_at(a) & Wall.West != 0
    elif dir.y == 1:
        return grid_at(a) & Wall.South != 0
    else:
        return grid_at(a) & Wall.North != 0


func _get_linked(cell: Vector2i) -> Array:
    var neighbors = _neighbors_of(cell)
    return neighbors.filter(func(c): _is_linked(cell, c))

func _dijkstra(start: Vector2i) -> Maze:
    var frontier = [ start ]

    distances.fill(0)
    var distance = 1

    while not frontier.is_empty():
        var next_frontier = Array()
        for f_cell in frontier:
            _set_dist_at(f_cell, distance)
            var linked_unvisited = \
                _get_linked(f_cell).filter(func(c): return dist_at(c) == 0)
            next_frontier.append_array(linked_unvisited)

        frontier = next_frontier
        distance += 1

    return self


func _cell_w_max_dist() -> Vector2i:
    var max_distance = 0
    var max_cell = Vector2i.ZERO
    for i in grid_width:
        for j in grid_height:
            var cell = Vector2i(i, j)
            if dist_at(cell) > max_distance:
                max_cell = cell

    return max_cell


func _calc_distances() -> Maze:
    _dijkstra(Vector2i.ZERO)
    exit = _cell_w_max_dist()
    _dijkstra(exit)
    entrance = _cell_w_max_dist()

    return self
