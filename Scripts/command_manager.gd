extends Node2D

@onready var grid = $"../Grid"
@onready var buildings_root = $"../Buildings"

const BUIDING_SCENE = preload("res://Scenes/tent.tscn")
const TILE_SIZE = Vector2i(16, 16)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var world_position =  get_global_mouse_position()
		var grid_position = grid.world_to_grid(world_position)
		
		if grid.is_walkable(grid_position):
			place_building(grid_position)
		else: 
			print("Tile is blocked")
	
func place_building(grid_position: Vector2i):
	var building = BUIDING_SCENE.instantiate()
	building.position = grid.grid_to_world(grid_position)
	buildings_root.add_child(building)
	grid.block_tile(grid_position)
			
