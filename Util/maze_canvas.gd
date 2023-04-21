extends Node2D


var _maze: Maze
var _settings: MazeSettings


func _ready():
    get_viewport().size_changed.connect(_on_resized)


func _on_resized():
    queue_redraw()


func _draw():
    for x in _settings.width:
        for y in _settings.height:
            _draw_cell(Vector2i(x, y))

    for x in _settings.width:
        for y in _settings.height:
            _draw_walls(Vector2i(x, y))

    if _settings.draw_entrance_exit:
        _draw_the_entrance_and_exit()

    if _settings.draw_solution:
        _draw_the_solution()


func draw_maze(maze: Maze, maze_settings: MazeSettings) -> void:
    _maze = maze
    _settings = maze_settings
    queue_redraw()


func _rect(cell: Vector2i) -> Rect2:
    var p1 = Vector2(cell.x * _settings.cell_size, cell.y * _settings.cell_size)
    var p2 = Vector2(_settings.cell_size, _settings.cell_size)
    return Rect2(p1, p2)


func _draw_cell(cell: Vector2i) -> void:
    var rect = _rect(cell)
    var color = _calculate_cell_color(cell)
    draw_rect(rect, color, true)


func _draw_walls(cell: Vector2i) -> void:
    var rect = _rect(cell)
    var p1 = rect.position
    var walls = _maze.grid_at(cell)
    var top_left: Vector2 = p1
    var top_right: Vector2 = top_left + Vector2(_settings.cell_size, 0)
    var bottom_left: Vector2 = top_left + Vector2(0, _settings.cell_size)
    var bottom_right: Vector2 = bottom_left + Vector2(_settings.cell_size, 0)

    var wt: float = _settings.wall_width * 0.5
    var x_nudge = Vector2(wt, 0)
    var y_nudge = Vector2(0, wt)

    if walls & Maze.Wall.North:
        draw_line(top_left - x_nudge, top_right + x_nudge, _settings.wall_color, _settings.wall_width)

    if walls & Maze.Wall.South:
        draw_line(bottom_left - x_nudge, bottom_right + x_nudge, _settings.wall_color, _settings.wall_width)

    if walls & Maze.Wall.West:
        draw_line(top_left - y_nudge, bottom_left + y_nudge, _settings.wall_color, _settings.wall_width)

    if walls & Maze.Wall.East:
        draw_line(top_right - y_nudge, bottom_right + y_nudge, _settings.wall_color, _settings.wall_width)


func _calculate_cell_color(cell: Vector2i) -> Color:
     if _settings.draw_gradient:
        var max_dist = _maze.get_max_distance()
        var cell_dist = _maze.dist_at(cell)
        var weight = cell_dist/float(max_dist)

        # This is the slow poke. Optimize this
        var result = lerp(_settings.odd_cell_color, _settings.even_cell_color, weight)
        return result

     else:
        return _settings.even_cell_color if (cell.x + cell.y) % 2 == 0 else _settings.odd_cell_color


func _draw_the_entrance_and_exit() -> void:
    var entrance: Rect2 = _rect(_maze.entrance)
    draw_circle(entrance.position + 0.5 * entrance.size, _settings.wall_width, _settings.path_color)
    var exit: Rect2 = _rect(_maze.exit)
    var exit_pos = exit.position + Vector2(_settings.cell_size * 0.5 - _settings.wall_width, _settings.cell_size * 0.5 - _settings.wall_width)
    draw_rect(Rect2(exit_pos, Vector2(_settings.wall_width * 2, _settings.wall_width * 2)), _settings.path_color)


func _find_next_in_path(from: Vector2i, to_cells: Array) -> Vector2i:
    var dist_from = _maze.dist_at(from)
    for cell in to_cells:
        if _maze.dist_at(cell) == dist_from - 1:
            return cell

    return Maze.NO_CELL


func _draw_the_solution():
    var from = _maze.entrance

    var points = Array()
    points.push_back(from)

    while from != _maze.exit:
        var possible_directions = _maze.get_linked(from)
        var chosen = _find_next_in_path(from, possible_directions)
        if chosen == Maze.NO_CELL:
            break

        points.push_back(chosen)
        from = chosen

    points = points \
        .map(func(p): return _rect(p)) \
        .map(func(r): return r.position + 0.5 * r.size)

    draw_polyline(points, _settings.path_color, _settings.wall_width * 0.62)
