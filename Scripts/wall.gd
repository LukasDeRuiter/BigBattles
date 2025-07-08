extends Building

class_name Wall

@onready var sprite := $Sprite

func _ready() -> void:
	super._ready()
	grid.register_wall(placed_grid_position, self)
	update_wall_sprite()
	update_neighbor_walls()
	
func die():
	grid.unregister_wall(placed_grid_position)
	super.die()
	update_neighbor_walls()
	
func update_wall_sprite():
	var position = placed_grid_position
	var bitmask := 0
	
	var directions = {
		Vector2i(0, -1): 1,
		Vector2i(1, 0): 2,
		Vector2i(0, 1): 4,
		Vector2i(-1, 0): 8,
	}
	
	for offset in directions:
		var neighbor = position + offset
		
		if grid.is_wall_at(neighbor):
			bitmask += directions[offset]
		
	sprite.frame = bitmask
	
func update_neighbor_walls():
	for offset in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var neighbor_position = placed_grid_position + offset
		var neighbor = grid.get_wall_at(neighbor_position)
		
		if neighbor:
			neighbor.update_wall_sprite()
