extends Node2D

@onready var grid = $"../Grid"
@onready var buildings_root = $"../Buildings"

const BUIDING_SCENE = preload("res://Scenes/tent.tscn")
const PREVIEW_SCENE = preload("res://Scenes/preview/tent_preview.tscn")
const TILE_SIZE = Vector2i(16, 16)

var preview_building = null
var preview_mode = false
var selected_building_data: BuildingData = null

func _ready() -> void:
	set_preview_active(false)
	
func set_preview_active(active: bool, building_data: BuildingData = null) -> void:
	if preview_mode and preview_building:
		preview_building.queue_free()
		
	preview_mode = active
	selected_building_data = building_data
	
	if preview_mode and selected_building_data:
			preview_building = selected_building_data.preview_scene.instantiate()
			add_child(preview_building)
			preview_building.show()
	else:
		if preview_building:
			preview_building.hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if preview_mode:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var world_position =  get_global_mouse_position()
			var grid_position = grid.world_to_grid(world_position)
		
			if grid.is_walkable(grid_position):
				place_building(grid_position)
			else: 
				print("Tile is blocked")
	
func place_building(grid_position: Vector2i) -> void:
	if not selected_building_data:
		return
		
	var building = selected_building_data.building_scene.instantiate()
	building.position = grid.grid_to_world(grid_position)
	buildings_root.add_child(building)
	grid.block_tile(grid_position)
	
func _process(delta):
	if preview_mode and preview_building:
		var world_position = get_global_mouse_position()
		var grid_position = grid.world_to_grid(world_position)
		var snapped_position = grid.grid_to_world(grid_position)
		
		preview_building.position =  snapped_position
		
		if grid.is_walkable(grid_position):
			preview_building.modulate = Color(0, 1, 0, 0.5)
		else:
			preview_building.modulate = Color(1, 0, 0, 0.5)
			
