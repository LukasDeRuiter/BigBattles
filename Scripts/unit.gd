extends CharacterBody2D

@export var selected = false
@export var move_sounds: Array[AudioStream]
@export var select_sounds: Array[AudioStream]
@export var data: UnitData

@onready var box = get_node("Box")
@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Sprite")
@onready var move_sound = get_node("MoveSound")
@onready var select_sound = get_node("SelectSound")
@onready var nav_agent = $NavigationAgent2D

const TileTypes = preload("res://Scripts/enums/tile_types.gd")

var target: Vector2 = Vector2.ZERO
var has_target := false
var follow_cursor = false
var speed = 50
var gathering := false
var terraforming := false
var terraforming_cancelled := false
var can_terraform := false
var gather_timer := 0.0
var gather_rate := 1.0
var can_gather_resources = false
var returning_to_base := false
var target_building = null
var building := false
var tilemap: TileMapLayer = null

var target_tile = null
var target_tile_coords = null
var target_tree: TreeObject = null
var target_gold_ore: GoldOreObject = null
var max_gather_amount = 10
var carried_wood := 0
var carried_gold := 0
	
func _ready():
	tilemap = get_tree().get_root().get_node("World/TileMapLayer")
	name = "Unit"
	set_selected(selected)
	add_to_group("units", true)
	target = global_position
	
func set_selected(value):
	selected = value
	box.visible = value

func _input(event):
	if selected:		
		if event.is_action_released("RightClick"):
			follow_cursor = true
			move_sound.stop()
			
			var all_units = get_tree().get_nodes_in_group("units")
				
			for unit in all_units:
				if unit.selected:
					if unit == self:
						if move_sounds.size() > 0:
							move_sound.stop()
							var index = randi() % move_sounds.size()
							move_sound.stream = move_sounds[index]
							move_sound.play()
					break
			
			follow_cursor = false
			move_to(get_global_mouse_position())
			gathering = false
			target_tree = null
			target_gold_ore = null
			target_building = null
			
			for building in get_tree().get_nodes_in_group("buildings"):
				if building is ConstructionSite:
					var collision_shape = building.get_node("CollisionShape2D")
					
					if collision_shape and collision_shape.shape:
							var shape = collision_shape.shape
							var mouse_pos = get_global_mouse_position()
							var global_pos = collision_shape.global_position
							var extents = shape.extents
							var rect = Rect2(global_pos - extents, extents * 2)
							
							if rect.has_point(mouse_pos):
								set_build_target(building)
			
			for object in get_tree().get_nodes_in_group("objects"):
				if object is TreeObject:
					var chop_area = object.get_node("chopArea") if object.has_node("chopArea") else null
					
					if chop_area:
						var collision_shape = chop_area.get_node("CollisionShape2D") if chop_area.has_node("CollisionShape2D") else null
						
						if collision_shape and collision_shape.shape:
							var shape = collision_shape.shape
							var mouse_pos = get_global_mouse_position()
							var global_pos = collision_shape.global_position
							var extents = shape.extents
							var rect = Rect2(global_pos - extents, extents * 2)
							
							if rect.has_point(mouse_pos):
								set_gather_target(object)
								break
				if object is GoldOreObject:
					var mine_area = object.get_node("mineArea") if object.has_node("mineArea") else null
					
					if mine_area:
						var collision_shape = mine_area.get_node("CollisionShape2D") if mine_area.has_node("CollisionShape2D") else null
						
						if collision_shape and collision_shape.shape:
							var shape = collision_shape.shape
							var mouse_pos = get_global_mouse_position()
							var global_pos = collision_shape.global_position
							var extents = shape.extents
							var rect = Rect2(global_pos - extents, extents * 2)
							
							if rect.has_point(mouse_pos):
								set_gather_target(object)
								break
								
			if can_terraform:
				var mouse_pos = get_global_mouse_position()
				var coordinates = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				
				var tile_data = tilemap.get_cell_tile_data(coordinates)
				
				if tile_data:
					var current_terrain = tile_data.get_custom_data("terrain")
					
					if current_terrain == "grass":
						var tilemap_layer = get_tree().get_root().get_node("World/TileMapLayer")
						var tileset = tilemap_layer.tile_set
						var tile_size = tileset.get_tile_size()
						var tile_size_f = Vector2(tile_size.x, tile_size.y)
						set_terraform_target(tilemap.map_to_local(coordinates) + tile_size_f / 2, coordinates)
						
						return
					elif current_terrain == "dirt":
						target_tile = null
						target_tile_coords = null
						terraforming = false
						terraforming_cancelled = true
						
						return
					
					
				
func _physics_process(delta):
	if follow_cursor and selected:
		move_to(get_global_mouse_position())
		
	if can_terraform and target_tile:
		if global_position.distance_to(target_tile_coords) < 10:
			animation.play("Terraform")
			start_terraforming(target_tile)
		
	if building and target_building:
		if global_position.distance_to(target_building.global_position) < 20:
			animation.play("Idle")
			target_building.add_worker(self)
		
	if returning_to_base:
		var deliver_area = target_building.get_node("deliverArea")
		if (deliver_area.get_overlapping_bodies().has(self)):
			returning_to_base = false
			target_building = null
			Game.wood += carried_wood
			Game.gold += carried_gold
			carried_wood = 0
			carried_gold = 0
			
			if target_tree:
				move_to(target_tree.global_position)
			if target_gold_ore:
				move_to(target_gold_ore.global_position)
				
			gathering = true

	if not nav_agent.is_navigation_finished():
		var next_position = nav_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		if abs(velocity.x) > abs(velocity.y):
			animation.play("WalkRight")
			sprite.flip_h = velocity.x < 0
		else:
			animation.play("Idle")
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	if gathering and target_tree:
		if global_position.distance_to(target_tree.global_position) < 20.0:
			animation.play("Idle")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_wood()
	
	if gathering and target_gold_ore:
		if global_position.distance_to(target_gold_ore.global_position) < 20.0:
			animation.play("Idle")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_gold()
				
	
		
func play_select_sound():
	if select_sounds.size() > 0:
		select_sound.stop()
		var index = randi() % select_sounds.size()
		select_sound.stream = select_sounds[index]
		select_sound.play()
	
func set_gather_target(object):
	if not can_gather_resources:
		print("Unit cannot gather resources")
		return
	
	if object is TreeObject:
		target_tree = object
		
	if object is GoldOreObject:
		target_gold_ore = object
		
	gathering = true
	gather_timer = 0.0
	move_to(object.global_position)
	
func move_to(position: Vector2):
	##target = position
	##has_target = true
	nav_agent.target_position = position
	
func collect_wood():
	if not target_tree:
		return
		
	if target_tree.has_method("gather"):
		select_sound.play()
		var gathered_wood = target_tree.gather(1)
		carried_wood += gathered_wood
		
		if target_tree.wood_amount <= 0:
			target_tree = find_closest_object("tree")
			
			if target_tree:
				move_to(target_tree.global_position)
			else:
				gathering = false
				
				return
		
		if carried_wood >= max_gather_amount:
			move_to(find_closest_collection_point())
			returning_to_base = true
			gathering = false
	else:
		print("Tree cannot be gathered")
		
func collect_gold():
	if not target_gold_ore:
		return
		
	if target_gold_ore.has_method("gather"):
		select_sound.play()
		var gathered_gold = target_gold_ore.gather(1)
		carried_gold += gathered_gold
		
		if target_gold_ore.gold_amount <= 0:
			target_gold_ore = find_closest_object("gold_ore")
			
			if target_gold_ore:
				move_to(target_gold_ore.global_position)
			else:
				gathering = false
				
				return
		
		if carried_gold >= max_gather_amount:
			move_to(find_closest_collection_point())
			returning_to_base = true
			gathering = false
	else:
		print("Gold ore cannot be gathered")

func find_closest_collection_point() -> Vector2:
	var closest_position = Vector2.ZERO
	var closest_distance = INF
	
	for building in get_tree().get_nodes_in_group("buildings"):
		if building.is_collection_point:
			var distance = global_position.distance_to(building.global_position)
			
			if distance < closest_distance:
				closest_distance = distance
				closest_position = building.global_position
				target_building = building
				
	return closest_position
	
func find_closest_object(name):
	var closest_object = null
	var closest_distance = INF
	
	for object in get_tree().get_nodes_in_group("objects"):
		if name == "tree":
			if object is TreeObject and object.wood_amount > 0:
				var distance = global_position.distance_to(object.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_object = object
					
		if name == "gold_ore":
			if object is GoldOreObject and object.gold_amount > 0:
				var distance = global_position.distance_to(object.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_object = object
					
	return closest_object
	
func set_build_target(site: ConstructionSite):
	move_to(site.global_position)
	target_building = site
	building = true
	
func set_terraform_target(moveLocation: Vector2, coords: Vector2i):
	move_to(moveLocation)
	target_tile = coords
	target_tile_coords = moveLocation
	
func start_terraforming(coords: Vector2i):
	if terraforming:
		return
		
	terraforming = true
	terraforming_cancelled = false
		
	await get_tree().create_timer(1.0).timeout
	
	if terraforming_cancelled:
		terraforming = false
		return
	
	var atlas_coords = TileTypes.ATLAS_COORDS["DIRT"]
	tilemap.set_cell(coords, 0, atlas_coords)
	terraforming = false
	target_tile = null
	target_tile_coords = null
	
	var adjacent_offsets = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]
	
	adjacent_offsets.shuffle()

	for offset in adjacent_offsets:
		var next_coords = coords + offset
		var tile_data = tilemap.get_cell_tile_data(next_coords)

		if tile_data and tile_data.get_custom_data("terrain") == "grass":
			var tile_size = tilemap.tile_set.get_tile_size()
			var world_pos = tilemap.map_to_local(next_coords) + Vector2(tile_size) / 2
			set_terraform_target(world_pos, next_coords)
			
			return
