extends Node2D

@onready var grid = $"../Grid"
@onready var buildings_root = $"../Buildings"
@onready var unit_training_panel = $"../UI/BottomPanel/UnitTrainingPanel"
@onready var unit_command_panel = $"../UI/BottomPanel/UnitCommandPanel"
@onready var building_panel = $"../UI/BottomPanel/BuildingPanel"
@onready var selection_panel = $"../UI/BottomPanel/SelectionPanel"

const TILE_SIZE = Vector2i(16, 16)
const TileTypes = preload("res://Scripts/enums/tile_types.gd")

var preview_building = null
var preview_mode = false
var selected_building_data: BuildingData = null
var selected_building = null
var selected_units = []
var tilemap: TileMapLayer = null

func _ready() -> void:
	set_preview_active(false)
	unit_training_panel.hide()
	unit_command_panel.hide()
	building_panel.show()
	tilemap = get_tree().get_root().get_node("World/TileMapLayer")
	
func set_preview_active(active: bool, building_data: BuildingData = null) -> void:
	if preview_mode and preview_building:
		preview_building.queue_free()
		
	preview_mode = active
	selected_building_data = building_data
	
	if preview_mode and selected_building_data:
			preview_building = selected_building_data.preview_scene.instantiate()
			preview_building.z_as_relative = false
			preview_building.z_index = 1000
			preview_building.get_node("CollisionShape2D").disabled = true
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
		
			if are_tiles_walkable(grid_position, selected_building_data.size):
				place_building(grid_position)
			elif preview_building is  SettlementBasis:
				place_settlement_basis(grid_position)
			else: 
				print("Tile is blocked")
				
	else:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if selected_building:
				selected_building.rally_point = get_global_mouse_position()
				
func are_tiles_walkable(start_pos: Vector2i, size: Vector2i) -> bool:
	var faction_tile = Game.player.faction.faction_tile
	
	for x in size.x:
		for y in size.y:
			var pos = start_pos + Vector2i(x, y)
			if not grid.is_walkable(pos):
				return false

			var local_coords = tilemap.local_to_map(grid.grid_to_world(pos) - tilemap.global_position)
			var atlas_coords = tilemap.get_cell_atlas_coords(local_coords)
			if atlas_coords != TileTypes.ATLAS_COORDS[faction_tile]:
				return false
				
			var world_position = grid.grid_to_world(pos)
			for object in get_tree().get_nodes_in_group("objects"):
				
				if not object.has_node("CollisionShape2D"):
					continue
					
				var shape_node = object.get_node("CollisionShape2D")
				if not shape_node.shape:
					continue

				var shape = shape_node.shape
				var object_pos = object.global_position

				var rect = Rect2(object_pos - shape.extents, shape.extents * 2)
				if rect.has_point(world_position):
					return false

	return true
	
func place_building(grid_position: Vector2i) -> void:
	if not selected_building_data:
		return
		
	var player = Game.player
	var construction_site = preload("res://Scenes/construction_site.tscn").instantiate()
	var base_position = grid.grid_to_world(grid_position)
	var center_offset = Vector2(selected_building_data.size * TILE_SIZE) / 2
	construction_site.position = base_position + center_offset
	construction_site.placed_grid_position = grid_position
	construction_site.building_data = selected_building_data
	construction_site.size = selected_building_data.size
	construction_site.icon = selected_building_data.icon
	construction_site.player_owner = player
	construction_site.player_id = player.player_id
	construction_site.building_tile = player.faction.faction_tile_blocked
	buildings_root.add_child(construction_site)
	
	for x in selected_building_data.size.x:
		for y in selected_building_data.size.y:
			grid.block_tile(grid_position + Vector2i(x, y))
			
			
func place_settlement_basis(grid_position: Vector2i) -> void:
	if not selected_building_data:
		return
	
	var faction_tile = Game.player.faction.faction_tile
	
	for x in selected_building_data.size.x:
		for y in selected_building_data.size.y:
			grid.add_navigation_to_tile(grid_position + Vector2i(x, y), faction_tile)
			
	var button = building_panel.get_node("PlaceSettlementBasis")
	
	if button:
		button.queue_free()
		set_preview_active(false)
	
func _process(delta):
	if preview_mode and preview_building:
		var world_position = get_global_mouse_position()
		var grid_position = grid.world_to_grid(world_position)
		var snapped_position = grid.grid_to_world(grid_position)
		preview_building.position = snapped_position + (Vector2(selected_building_data.size * TILE_SIZE) / 2)
		
		if are_tiles_walkable(grid_position, selected_building_data.size) or preview_building is SettlementBasis:
			preview_building.modulate = Color(0, 1, 0, 0.5)
		else:
			preview_building.modulate = Color(1, 0, 0, 0.5)
			
func select_building(building_node):
	selected_building = building_node
	selected_building.selectBuilding()
	building_panel.hide()
	unit_training_panel.show_for_building(selected_building)
	unit_training_panel.show()
	
func deselect_building():
	selected_building = null
	unit_training_panel.hide_panel()
	building_panel.show()
	
func _on_camera_click(pos: Vector2):
	if get_viewport().gui_get_focus_owner():
		return
		
	if not preview_mode:
		var clicked_unit = null
		var clicked_building = null
			
		for unit in get_tree().get_nodes_in_group("units"):
			var sprite = unit.get_node("Sprite")
			var rect = Rect2(unit.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
			
			if rect.has_point(pos):
				clicked_unit = unit
				clicked_unit.play_select_sound()
				break
		if not clicked_unit:
			unit_command_panel.hide()
			for building in get_tree().get_nodes_in_group("buildings"):
				var sprite = building.get_node("Sprite")
				var rect = Rect2(building.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
				if rect.has_point(pos):
					clicked_building = building
					break

		clear_selection()
		
		if clicked_unit:
			clicked_unit.set_selected(true)
			swap_command_panel()
			building_panel.hide()
			selection_panel.show_units([clicked_unit])
		elif clicked_building:
			clicked_building.set_selected(true)
			unit_command_panel.hide()
			selection_panel.show_building(clicked_building)

func _on_camera_drag(rect: Rect2):
	clear_selection()
	
	for unit in get_tree().get_nodes_in_group("units"):
		if rect.has_point(unit.global_position):
			unit.set_selected(true)
			selected_units.append(unit)
			swap_command_panel()
			
	if selected_units.size() == 0:
		unit_command_panel.hide()
		
		for building in get_tree().get_nodes_in_group("buildings"):
			if rect.has_point(building.global_position):
				select_building(building)
				selection_panel.show_building(building)
				break
	else: 
		selection_panel.show_units(selected_units)
		selected_units[0].play_select_sound()

func clear_selection():		
	selection_panel.clear()
	building_panel.show()
	selected_units.clear()
	
	for unit in get_tree().get_nodes_in_group("units"):
		unit.set_selected(false)
	for building in get_tree().get_nodes_in_group("buildings"):
		building.set_selected(false)

func swap_command_panel():
	unit_command_panel.show()
	building_panel.hide()


func set_unit_stance(stance: String):
	for unit in selected_units:
		if stance == "GUARD":
			unit.is_in_guard_mode = true
		else:
			unit.is_in_guard_mode = false

func get_unit_stances():
	var stances = []
	
	for unit in selected_units:
		if unit.is_in_guard_mode:
			if "GUARD" not in stances:
				stances.append("GUARD")
		else:
			if "AGGRESSIVE" not in stances:
				stances.append("AGGRESSIVE")
	
	return stances
	
