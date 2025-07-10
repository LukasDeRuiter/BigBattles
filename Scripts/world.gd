extends Node2D

var units =  []
var buildings = []

var tile_size = 16
var grid_size = Vector2(160, 160)

@onready var command_manager = $CommandManager
@onready var pause_menu = $PauseMenu
@onready var grid = $Grid
@onready var tilemap = $TileMapLayer
@onready var objects = $Objects
@onready var tree = preload("res://Scenes/objects/tree.tscn")
@onready var gold_ore = preload("res://Scenes/objects/gold_ore.tscn")

const TileTypes = preload("res://Scripts/enums/tile_types.gd")

## Survival Mode
@onready var wave_timer = Timer.new()
var wave = 0

func _ready():
	get_units()
	
	if Game.current_mode == "SURVIVAL":
		setup_survival_mode()
	
	generate_world()
	
func _process(delta):
	if Game.current_mode == "SURVIVAL":
		Game.wave_counter = wave_timer.time_left
	
func generate_world():
	var tilemap_bounds = tilemap.get_used_rect()
	
	var world_rect = Rect2(
	tilemap_bounds.position * tilemap.tile_set.tile_size,
	tilemap_bounds.size * tilemap.tile_set.tile_size
)
	
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	noise.seed = randi() 
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
				
			var raw_value = noise.get_noise_2d(x, y)
			var scaled_value = int(((raw_value + 1.0) / 2.0) * 1000)
			var tile_type = "GRASS"
	
			if scaled_value > 500:
				tile_type = "GRASS"
			elif scaled_value > 400:
				tile_type = "DIRT"
			else:
				tile_type = "WATER"
			
			var atlas_coords = TileTypes.ATLAS_COORDS[tile_type]
			tilemap.set_cell(Vector2i(x, y), 0, atlas_coords)
			if tile_type == "GRASS" and Game.current_mode != "SURVIVAL":
				if scaled_value > 600:
					var tree_instance = tree.instantiate()
					tree_instance.position = Vector2(x, y) * tile_size + Vector2(tile_size, tile_size) / 2
					objects.add_child(tree_instance)
					tree_instance.add_to_group("objects", true)
					var grid_pos = grid.world_to_grid(tree_instance.position)
					grid.register_tree(grid_pos, tree_instance)
					grid.block_tile(grid_pos)
					grid.block_tile_navigation(grid_pos)
				elif randf() < 0.01:
					var gold_instance = gold_ore.instantiate()
					gold_instance.position = Vector2(x, y) * tile_size + Vector2(tile_size, tile_size) / 2
					objects.add_child(gold_instance)
					var gold_grid_pos = grid.world_to_grid(gold_instance.position)
					grid.register_gold_ore(gold_grid_pos, gold_instance)
					grid.block_tile(gold_grid_pos)
					grid.block_tile_navigation(gold_grid_pos)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
			
func pause_game():
	get_tree().paused = true
	pause_menu.visible = true
	
func resume_game():
	get_tree().paused = false
	pause_menu.visible = false
	
func get_units():
	units = null
	units = get_tree().get_nodes_in_group("units")

func get_buildings():
	buildings = null
	buildings = get_tree().get_nodes_in_group("buildings")

func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area = []
	
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	
	var ut = get_units_in_area(area)
	var allUnits = get_tree().get_nodes_in_group("units")
	
	for u in allUnits:
		u.set_selected(false)
		
	var buildings = $Buildings.get_children()
	for building in buildings :
		building.deselectBuilding()
		
	if ut.size() > 0:
		for u in ut:
			u.set_selected(!u.selected)
			ut[0].play_select_sound()
			command_manager.deselect_building()
	else:
		var building = get_building_in_area(area)
		if building:
			command_manager.select_building(building)
		else: 
			command_manager.deselect_building()
		
	
func get_units_in_area(area):
	var u = []
	
	## Check if units are inside the selection box
	for unit in get_tree().get_nodes_in_group("units"):
		if (unit.position.x > area[0].x) and (unit.position.x < area[1].x):
			if (unit.position.y > area[0].y) and (unit.position.y < area[1].y):
				u.append(unit)
				pass
	
	return u;
	
func get_building_in_area(area):
	var buildings = $Buildings.get_children()
	for building in buildings :
		var position = building.global_position
		if (position.x > area[0].x and position.x < area[1].x and position.y > area[0].y and position.y < area[1].y):
			return building
			
	return null
			
func setup_survival_mode():
	wave_timer.wait_time = 60
	wave_timer.one_shot = false
	wave_timer.connect("timeout", Callable(self, "_on_survival_wave_timeout"))
	add_child(wave_timer)
	wave_timer.start()

func _on_survival_wave_timeout():
	wave += 1
	Game.wave = wave
		
	spawn_wave(wave)
	
func spawn_wave(wave_number: int):
	var count = 3 + wave_number * 2
	for i in range(count):
		var enemy = preload("res://Scenes/units/skeleton.tscn").instantiate()
		enemy.player_id = 3
		enemy.global_position = get_random_edge_position()
		add_child(enemy)
		var attack_target = get_random_building_or_unit()
		enemy.move_to(attack_target.global_position)
		
		
func get_random_edge_position() -> Vector2:
	var edge_positions: Array[Vector2i] = []

	# Infer grid size from your grid_data keys (fallback to 160 if empty)
	var grid_width = 160
	var grid_height = 160

	if grid.grid_data.size() > 0:
		for pos in grid.grid_data.keys():
			grid_width = max(grid_width, pos.x + 1)
			grid_height = max(grid_height, pos.y + 1)

	# Top and Bottom edges
	for x in range(grid_width):
		var top = Vector2i(x, 0)
		var bottom = Vector2i(x, grid_height - 1)
		if grid.is_walkable(top):
			edge_positions.append(top)
		if grid.is_walkable(bottom):
			edge_positions.append(bottom)

	# Left and Right edges
	for y in range(grid_height):
		var left = Vector2i(0, y)
		var right = Vector2i(grid_width - 1, y)
		if grid.is_walkable(left):
			edge_positions.append(left)
		if grid.is_walkable(right):
			edge_positions.append(right)

	if edge_positions.size() == 0:
		return Vector2.ZERO  # fallback
	
	var grid_pos = edge_positions[randi() % edge_positions.size()]
	return grid.grid_to_world(grid_pos) + Vector2(8, 8)  # center of tile


func get_random_building_or_unit() -> Node2D:
	var candidates: Array = []
	
	var all_units = get_tree().get_nodes_in_group("units")
	var all_buildings = get_tree().get_nodes_in_group("buildings")

	for unit in all_units:
		if unit.player_id == 1:
			candidates.append(unit)

	for building in all_buildings:
		if building.player_id == 1:
			candidates.append(building)

	if candidates.size() == 0:
		return null
	
	return candidates[randi() % candidates.size()]
