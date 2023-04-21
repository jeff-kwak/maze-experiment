extends Control


signal draw_maze()
signal center_maze()


var settings: MazeSettings:
    get:
        return _settings


var _settings: MazeSettings


@onready var _seed_line_edit: LineEdit = %SeedLineEdit
@onready var _seed_label: Label = %SeedLabel
@onready var _width_spin_box: SpinBox = %WidthSpinBox
@onready var _height_spin_box: SpinBox = %HeightSpinBox
@onready var _cell_size_spin_box: SpinBox = %CellSizeSpinBox
@onready var _wall_width_spin_box: SpinBox = %WallWidthSpinBox
@onready var _even_color_picker: ColorPickerButton = %EvenCellColorPickerButton
@onready var _odd_color_picker: ColorPickerButton = %OddCellColorPickerButton
@onready var _wall_color_picker: ColorPickerButton = %WallColorPickerButton
@onready var _path_color_picker: ColorPickerButton = %PathColorPickerButton
@onready var _draw_gradient_check_box: CheckBox = %DrawGradientCheckBox
@onready var _draw_entrance_exit_check_box: CheckBox = %DrawEntranceExitCheckBox
@onready var _draw_solution_check_box: CheckBox = %DrawSolutionCheckBox


func _ready():
    _seed_line_edit.text_changed.connect(_on_seed_line_changed)


func bind(maze_settings: MazeSettings):
    print("maze_control_side_panel: binding maze settings")
    _settings = maze_settings
    _seed_line_edit.text = _settings.maze_seed_word
    _seed_label.text = str(_settings.maze_seed_hash)
    _width_spin_box.value = _settings.width
    _height_spin_box.value = _settings.height
    _cell_size_spin_box.value = _settings.cell_size
    _wall_width_spin_box.value = _settings.wall_width
    _even_color_picker.color = _settings.even_cell_color
    _odd_color_picker.color = _settings.odd_cell_color
    _wall_color_picker.color = _settings.wall_color
    _path_color_picker.color = _settings.path_color
    _draw_gradient_check_box.button_pressed = _settings.draw_gradient
    _draw_entrance_exit_check_box.button_pressed = _settings.draw_entrance_exit
    _draw_solution_check_box.button_pressed = _settings.draw_solution


func _on_center_button_pressed():
    center_maze.emit()


func _on_draw_button_pressed():
    _seed_label.text = str(_settings.maze_seed_hash) # only show on draw click
    draw_maze.emit()


func _on_seed_line_changed(value: String):
    _settings.maze_seed_word = value.strip_edges(true, true)


func _on_width_spin_box_value_changed(value:float):
    _settings.width = int(value)


func _on_height_spin_box_value_changed(value:float):
    _settings.height = int(value)


func _on_cell_size_spin_box_value_changed(value:float):
    _settings.cell_size = int(value)


func _on_wall_width_spin_box_value_changed(value:float):
    _settings.wall_width = int(value)


func _on_even_cell_color_picker_button_color_changed(color:Color):
    _settings.even_cell_color = color


func _on_odd_cell_color_picker_button_color_changed(color:Color):
    _settings.odd_cell_color = color


func _on_wall_color_picker_button_color_changed(color:Color):
    _settings.wall_color = color


func _on_path_color_picker_button_color_changed(color:Color):
    _settings.path_color = color


func _on_draw_gradient_check_box_toggled(button_pressed:bool):
    _settings.draw_gradient = button_pressed


func _on_draw_solution_check_box_toggled(button_pressed:bool):
    _settings.draw_solution = button_pressed


func _on_draw_entrance_exit_check_box_toggled(button_pressed:bool):
    _settings.draw_entrance_exit = button_pressed
