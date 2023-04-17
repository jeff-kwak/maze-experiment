extends Control


signal draw_maze()
signal center_maze()


var settings: MazeSettings:
    get:
        return _settings


var _settings: MazeSettings


@onready var _seed_line_edit: LineEdit = %SeedLineEdit
@onready var _seed_label: Label = %SeedLabel


func _ready():
    _seed_line_edit.text_changed.connect(_on_seed_line_changed)


func bind(maze_settings: MazeSettings):
    print("maze_control_side_panel: binding maze settings")
    _settings = maze_settings
    _seed_line_edit.text = _settings.maze_seed_word
    _seed_label.text = str(_settings.maze_seed_hash)



    # TODO: You are here in the binding. You only have the
    # maze word as you elected to separate the word from the
    # seeds hash for display purposes


func _on_center_button_pressed():
    pass # Replace with function body.


func _on_draw_button_pressed():
    _seed_label.text = str(_settings.maze_seed_hash) # only show on draw click
    draw_maze.emit()


func _on_seed_line_changed(value: String):
    _settings.maze_seed_word = value.strip_edges(true, true)
