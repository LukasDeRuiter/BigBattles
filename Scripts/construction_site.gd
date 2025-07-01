extends StaticBody2D

class_name ConstructionSite

@export var building_data: BuildingData
@export var size: Vector2i

@onready var progress_bar = $ProgressBar
@onready var select = get_node("Selected")
@onready var command_manager = $"../../CommandManager"

var TILE_SIZE = Vector2(16, 16) 

var selected = false
var construction_progress := 0.0
var workers := []
var required_progress := 10.0
var rally_point: Vector2
var placed_grid_position: Vector2i
var icon: Texture2D

func _ready():
	add_to_group("buildings", true)
	progress_bar.max_value = required_progress
	progress_bar.value = construction_progress
	progress_bar.visible = true
	rally_point = global_position
	
func add_worker(unit):
	if unit not in workers:
		workers.append(unit)
		
func _process(delta):
	if workers.size() == 0:
		return
		
	construction_progress += workers.size() * delta * 5
	progress_bar.value = construction_progress
	
	if construction_progress >= required_progress:
		complete_progress()
		
func set_selected(value):
	selected = value
	select.visible = value
	
	if selected == true:
		command_manager.select_building(self)
	else: 
		command_manager.deselect_building()
		
func selectBuilding():
	selected = true
	
func deselectBuilding():
	selected = false
	
func complete_progress():
	var building = building_data.building_scene.instantiate()
	building.position = position
	building.health = building_data.health
	building.max_health = building_data.health
	building.size = building_data.size
	building.trainable_units = building_data.trainable_units
	building.is_collection_point = building_data.is_collection_point
	building.placed_grid_position = placed_grid_position
	building.icon = building_data.icon
	building.displayName = building_data.name

	if building is not Farm:
		var grid = get_tree().get_root().get_node("World/Grid")
		
		for x in building.size.x:
			for y in building.size.y:
				grid.block_tile_navigation(placed_grid_position + Vector2i(x, y))
	
	get_parent().add_child(building)
	queue_free()
	
	
	
