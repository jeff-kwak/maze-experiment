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


