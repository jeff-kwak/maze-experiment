extends Node2D

@export var Width: int = 10
@export var Height: int = 10
@export var CellSize: int = 16
@export var WallThickness: int = 2
@export var Seed: String = ""

var _maze: Maze
var _redraw: bool

func _ready():
    _maze = Maze.new(Width, Height)
    var rng_seed = 0 if Seed.is_empty() else hash(Seed)
    _maze = _maze.recursive_back_tracker(rng_seed)
    _redraw = true

func _draw():
    if _redraw:
        for x in Width:
            for y in Height:
                _draw_cell(Vector2i(x, y))
        _redraw = false

func _draw_cell(cell: Vector2i) -> void:
    # draw the floor
    var p1 = Vector2(cell.x * CellSize, cell.y * CellSize)
    var p2 = Vector2(CellSize, CellSize)
    var rect = Rect2(p1, p2)
    var color = Color.WHITE if (cell.x + cell.y) % 2 == 0 else Color.LIGHT_BLUE
    draw_rect(rect, color, true)

    # draw the walls
    var walls = _maze.data_at(cell)
    var top_left: Vector2 = p1
    var top_right: Vector2 = top_left + Vector2(CellSize, 0)
    var bottom_left: Vector2 = top_left + Vector2(0, CellSize)
    var bottom_right: Vector2 = bottom_left + Vector2(CellSize, 0)

    if walls & Maze.Wall.North:
        draw_line(top_left, top_right, Color.BLACK, WallThickness)

    if walls & Maze.Wall.South:
        draw_line(bottom_left, bottom_right, Color.BLACK, WallThickness)

    if walls & Maze.Wall.West:
        draw_line(top_left, bottom_left, Color.BLACK, WallThickness)

    if walls & Maze.Wall.East:
        draw_line(top_right, bottom_right, Color.BLACK, WallThickness)
