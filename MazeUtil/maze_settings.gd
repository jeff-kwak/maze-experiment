class_name MazeSettings
extends Resource


var _maze_seed_word: String = ""


@export var maze_seed_word:String:
    get:
        return _maze_seed_word

    set(value):
        _maze_seed_word = value


var maze_seed_hash: int:
    get:
        if _maze_seed_word.is_empty():
            return int(Time.get_unix_time_from_system() * 1000)
        else:
            return int(_maze_seed_word) if _maze_seed_word.is_valid_int() else hash(_maze_seed_word)


@export var width: int = 9
@export var height: int = 9
@export var cell_size: int = 16
@export var wall_width: int = 5
@export var even_cell_color: Color = Color.WHITE
@export var odd_cell_color: Color = Color.LIGHT_BLUE
@export var wall_color: Color = Color.BLACK
@export var path_color: Color = Color.BLACK
@export var draw_gradient: bool = false
@export var draw_entrance_exit: bool = false
@export var draw_solution: bool = false
