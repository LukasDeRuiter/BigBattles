extends Node2D

@export var grid_width: int = 128
@export var grid_height: int = 128
@export var tile_size: int = 16
@export var color: Color = Color(0.3, 1.0, 0.3, 0.5)  # semi-transparent green

func _draw():
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2(x, y) * tile_size
			draw_rect(Rect2(pos, Vector2(tile_size, tile_size)), color, false)
