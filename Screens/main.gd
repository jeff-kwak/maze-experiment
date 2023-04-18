extends Node2D

var MAZE_SETTINGS_PATH: String = "user://maze_settings.tres"

@export var MinZoom = 0.2
@export var MaxZoom = 2
@export var ZoomStep = 0.1


var _maze_settings: MazeSettings
var _maze: Maze
var _zoom_factor: float = 1.0
var _is_panning: bool = false


@onready var _camera = $Camera2D
@onready var _maze_canvas = $MazeCanvas
@onready var _maze_settings_size_panel = $CanvasLayer/MazeControlSidePanel


func _ready():
    _load_settings()
    _draw_maze()


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
    var x = _maze_settings.width * _maze_settings.cell_size * 0.5
    var y = _maze_settings.height * _maze_settings.cell_size * 0.5
    _camera.position_camera(x, y)


func _build_maze():
    _maze = Maze.new(_maze_settings.width, _maze_settings.height)
    _maze = _maze.recursive_back_tracker(_maze_settings.maze_seed_hash)


func _load_settings():
    if ResourceLoader.exists(MAZE_SETTINGS_PATH):
        print("main: loading existing resource file: %s" % MAZE_SETTINGS_PATH)
        _maze_settings = ResourceLoader.load(MAZE_SETTINGS_PATH)
    else:
        print("main: creating new resource file")
        _maze_settings = MazeSettings.new()

    _maze_settings_size_panel.bind(_maze_settings)


func _on_draw_maze():
    _maze_settings = _maze_settings_size_panel.settings
    print("main: building maze with seed: %s" % _maze_settings.maze_seed_word)
    ResourceSaver.save(_maze_settings, MAZE_SETTINGS_PATH)
    _draw_maze()


func _draw_maze() -> void:
    _build_maze()
    _center_camera()
    _camera.change_zoom(_zoom_factor)
    _maze_canvas.draw_maze(_maze, _maze_settings)
