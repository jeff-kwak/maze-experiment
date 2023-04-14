extends Node2D

@export var Width: int = 10
@export var Height: int = 10
@export var CellSize: int = 16
@export var WallThickness: int = 2
@export var Seed: String = ""
@export var MinZoom = 0.2
@export var MaxZoom = 2
@export var ZoomStep = 0.1

@onready var _camera = $Camera2D
@onready var _maze_canvas = $MazeCanvas

var _maze: Maze
var _zoom_factor: float = 1.0
var _is_panning: bool = false

func _ready():
    _build_maze()
    _center_camera()
    _camera.change_zoom(_zoom_factor)
    _maze_canvas.draw_maze(_maze, CellSize, WallThickness)

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.is_pressed():
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                _zoom_factor = clampf(_zoom_factor - ZoomStep, MinZoom, MaxZoom)
                _camera.change_zoom(_zoom_factor)

            if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                _zoom_factor = clampf(_zoom_factor + ZoomStep, MinZoom, MaxZoom)
                _camera.change_zoom(_zoom_factor)

            if event.button_index == MOUSE_BUTTON_LEFT:
                _is_panning = true

        if not event.is_pressed():
            if event.button_index == MOUSE_BUTTON_LEFT:
                _is_panning = false

    if event is InputEventMouseMotion:
        if _is_panning:
            _camera.move(event.relative)

func _center_camera():
    var x = Width * CellSize * 0.5
    var y = Height * CellSize * 0.5
    _camera.position_camera(x, y)

func _build_maze():
    _maze = Maze.new(Width, Height)
    var rng_seed = 0 if Seed.is_empty() else hash(Seed)
    _maze = _maze.recursive_back_tracker(rng_seed)
