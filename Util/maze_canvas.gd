extends Node2D


var _maze: Maze
var _width: int = 0
var _height: int = 0
var _cell_size: int = 16
var _wall_thickness: int = 5
var _even_cell_color: Color = Color.WHITE
var _odd_cell_color: Color = Color.WHITE
var _wall_color: Color = Color.BLACK


func _ready():
    get_viewport().size_changed.connect(_on_resized)


func _on_resized():
    queue_redraw()


func _draw():
    for x in _width:
        for y in _height:
            _draw_cell(Vector2i(x, y))

    for x in _width:
        for y in _height:
            _draw_walls(Vector2i(x, y))


func draw_maze(maze: Maze, maze_settings: MazeSettings) -> void:
    _maze = maze
    _width = maze.grid_width
    _height = maze.grid_height
    _cell_size = maze_settings.cell_size
    _wall_thickness = maze_settings.wall_width
    _even_cell_color = maze_settings.even_cell_color
    _odd_cell_color = maze_settings.odd_cell_color
    _wall_color = maze_settings.wall_color
    queue_redraw()


func _rect(cell: Vector2i) -> Rect2:
    var p1 = Vector2(cell.x * _cell_size, cell.y * _cell_size)
    var p2 = Vector2(_cell_size, _cell_size)
    return Rect2(p1, p2)

func _draw_cell(cell: Vector2i) -> void:
    # draw the floor
    var rect = _rect(cell)
    var color = _even_cell_color if (cell.x + cell.y) % 2 == 0 else _odd_cell_color
    draw_rect(rect, color, true)

func _draw_walls(cell: Vector2i) -> void:
    # draw the walls
    var rect = _rect(cell)
    var p1 = rect.position
    var walls = _maze.grid_at(cell)
    var top_left: Vector2 = p1
    var top_right: Vector2 = top_left + Vector2(_cell_size, 0)
    var bottom_left: Vector2 = top_left + Vector2(0, _cell_size)
    var bottom_right: Vector2 = bottom_left + Vector2(_cell_size, 0)

    var wt: float = _wall_thickness * 0.5
    var x_nudge = Vector2(wt, 0)
    var y_nudge = Vector2(0, wt)

    if walls & Maze.Wall.North:
        draw_line(top_left - x_nudge, top_right + x_nudge, _wall_color, _wall_thickness)

    if walls & Maze.Wall.South:
        draw_line(bottom_left - x_nudge, bottom_right + x_nudge, _wall_color, _wall_thickness)

    if walls & Maze.Wall.West:
        draw_line(top_left - y_nudge, bottom_left + y_nudge, _wall_color, _wall_thickness)

    if walls & Maze.Wall.East:
        draw_line(top_right - y_nudge, bottom_right + y_nudge, _wall_color, _wall_thickness)