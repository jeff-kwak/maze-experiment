extends Camera2D


func position_camera(x, y):
    position = Vector2(x, y)


func change_zoom(zoom_factor: float) -> void:
    zoom = Vector2(zoom_factor, zoom_factor)


func move(relative: Vector2) -> void:
    position -= relative / zoom
