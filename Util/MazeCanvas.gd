extends Node2D

var _redraw: bool = false
var _maze: Maze
var _width: int = 0
var _height: int = 0
var _cell_size: int = 16
var _wall_thickness: int = 5

func draw_maze(maze: Maze, cell_size: int, wall_thickness: int) -> void:
    _maze = maze
    _width = maze.grid_width
    _height = maze.grid_height
    _cell_size = cell_size
    _wall_thickness = wall_thickness
    _redraw = true

# Called when the node enters the scene tree for the first time.
func _ready():
    get_viewport().connect("size_changed", _on_resized)

func _on_resized():
    _redraw = true

func _draw():
    if _redraw:
        for x in _width:
            for y in _height:
                _draw_cell(Vector2i(x, y))
        _redraw = false

func _draw_cell(cell: Vector2i) -> void:
    # draw the floor
    var p1 = Vector2(cell.x * _cell_size, cell.y * _cell_size)
    var p2 = Vector2(_cell_size, _cell_size)
    var rect = Rect2(p1, p2)
    var color = Color.WHITE if (cell.x + cell.y) % 2 == 0 else Color.LIGHT_BLUE
    draw_rect(rect, color, true)

    # draw the walls
    var walls = _maze.data_at(cell)
    var top_left: Vector2 = p1
    var top_right: Vector2 = top_left + Vector2(_cell_size, 0)
    var bottom_left: Vector2 = top_left + Vector2(0, _cell_size)
    var bottom_right: Vector2 = bottom_left + Vector2(_cell_size, 0)

    if walls & Maze.Wall.North:
        draw_line(top_left, top_right, Color.BLACK, _wall_thickness)

    if walls & Maze.Wall.South:
        draw_line(bottom_left, bottom_right, Color.BLACK, _wall_thickness)

    if walls & Maze.Wall.West:
        draw_line(top_left, bottom_left, Color.BLACK, _wall_thickness)

    if walls & Maze.Wall.East:
        draw_line(top_right, bottom_right, Color.BLACK, _wall_thickness)
