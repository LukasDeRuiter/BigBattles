extends CharacterBody2D

class_name Unit

signal health_changed(new_health)

@export var selected = false
@export var move_sounds: Array[AudioStream]
@export var select_sounds: Array[AudioStream]
@export var activity_sounds: Array[AudioStream]
@export var attack_sounds: Array[AudioStream]
@export var player_owner: Player
@export var player_id: int
@export var data: UnitData

@onready var box = get_node("Box")
@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Sprite")
@onready var move_sound = get_node("MoveSound")
@onready var select_sound = get_node("SelectSound")
@onready var activity_sound = get_node("ActivitySound")
@onready var attack_sound = get_node("AttackSound")
@onready var nav_agent = $NavigationAgent2D
@onready var health_bar = $ProgressBar
@onready var combat_follow_timer = $CombatFollowTimer
@onready var combat_detection_zone = $CombatDetectionZone
@onready var sound_manager = get_tree().get_root().get_node("World/SoundManager") 
@onready var world = get_tree().get_root().get_node("World")
@onready var grid = get_tree().get_root().get_node("World/Grid") 

const TileTypes = preload("res://Scripts/enums/tile_types.gd")
var bones_scene = preload("res://Scenes/bones.tscn")
var popup = preload("res://Scenes/popup.tscn")

var displayName: String
var target: Vector2 = Vector2.ZERO
var has_target := false
var follow_cursor = false
var speed: int = 50
var gathering := false
var terraforming := false
var terraforming_cancelled := false
var can_terraform := false
var gather_timer := 0.0
var gather_rate := 1.0
var can_gather_resources = false
var returning_to_base := false
var target_building = null
var target_farm = null
var can_build := false
var building := false
var tilemap: TileMapLayer = null
var is_playing_activity_sound := false
var activity_sound_timer := 0.0
var activity_sound_interval := 1.0 
var icon: Texture2D
var is_ranged_unit: bool = false
var projectile_scene: PackedScene
var projectile_speed: float = 200.0

var target_tile = null
var target_tile_coords = null
var terraforming_frontier := []
var explored := {}
var target_tree: TreeObject = null
var target_gold_ore: GoldOreObject = null
var max_gather_amount = 10
var carried_food := 0
var carried_wood := 0
var carried_gold := 0

var health: int = 100
var max_health: int = 100
var attack_damage: int = 10
var attack_range: float = 32.0
var attack_cooldown: float = 1.0
var is_combat_unit: bool = true

var combat_target = null
var attack_timer: float = 0.0
	
func _ready():
	tilemap = get_tree().get_root().get_node("World/TileMapLayer")
	set_selected(selected)
	add_to_group("units", true)
	target = global_position
	
	if data:
		displayName = data.name
		can_build = data.can_build
		can_gather_resources = data.can_gather_resources
		can_terraform = data.can_terraform
		is_combat_unit = data.is_combat_unit
		health = data.health
		attack_damage = data.attack_damage
		attack_range = data.attack_range
		attack_cooldown = data.attack_cooldown
		icon = data.icon
		speed = data.speed
		is_ranged_unit = data.is_ranged_unit
		projectile_scene = data.projectile_scene
		projectile_speed = data.projectile_speed
		
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false
	max_health = health
	
	animation.play("Idle")
	
func set_selected(value):
	selected = value
	box.visible = value

func _input(event):
	var grid_pos = grid.world_to_grid(get_global_mouse_position())
	
	if selected:		
		if event.is_action_released("RightClick"):
			follow_cursor = true
			move_sound.stop()
			attack_sound.stop()
			follow_cursor = false
			gathering = false
			returning_to_base = false
			target_tree = null
			target_gold_ore = null
			target_building = null
			target_farm = null
			combat_target = null
			
			if can_build:
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
			
			if can_gather_resources:
				if grid.farms.has(grid_pos):
					var farm = grid.farms[grid_pos]
					if not farm.isOccupied:
						set_gather_target(farm)
						return

				if grid.trees.has(grid_pos):
					set_gather_target(grid.trees[grid_pos])
					return

				if grid.gold_ores.has(grid_pos):
					set_gather_target(grid.gold_ores[grid_pos])
					return
				
			if is_combat_unit:
				for unit in get_tree().get_nodes_in_group("units"):
					if unit != self and unit.player_id != player_id:
						var collision_shape = unit.get_node("CollisionShape2D") if unit.has_node("CollisionShape2D") else null
							
						if collision_shape and collision_shape.shape:
							if is_mouse_over_shape(collision_shape, get_global_mouse_position()):
								play_attack_sound()
								combat_target = unit
								move_to(unit.global_position)
								break
								
				for building in get_tree().get_nodes_in_group("buildings"):
					if building.player_id != player_id:
						var collision_shape = building.get_node("CollisionShape2D") if building.has_node("CollisionShape2D") else null
								
						if collision_shape and collision_shape.shape:
							var shape = collision_shape.shape
							var mouse_pos = get_global_mouse_position()
							var global_pos = collision_shape.global_position
							var extents = shape.extents
							var rect = Rect2(global_pos - extents, extents * 2)
									
							if rect.has_point(mouse_pos):
								play_attack_sound()
								combat_target = building
								move_to(building.global_position)
								break
									
			if can_terraform:
				var mouse_pos = get_global_mouse_position()
				var coordinates = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				var tile_found = attempt_terraform_tile(coordinates)
					
			if !combat_target:
				play_move_sound()
			move_to(get_global_mouse_position())
				
func _physics_process(delta):
	activity_sound_timer += delta
	
	if follow_cursor and selected:
		move_to(get_global_mouse_position())
		
	if can_terraform and target_tile:
		if global_position.distance_to(target_tile_coords) < 16:
			animation.play("Terraform")
			
			if not is_playing_activity_sound:
				play_activity_sound(3)
				is_playing_activity_sound = true

			start_terraforming(target_tile)
		
	if building and target_building:		
		if global_position.distance_to(target_building.global_position) < 20:
			if animation.has_animation("Build"):
				animation.play("Build")
				
			play_activity_sound(0)
			target_building.add_worker(self)
		
	if returning_to_base and target_building:
		var deliver_area = target_building.get_node("deliverArea")
		if (deliver_area.get_overlapping_bodies().has(self)):
			target_building.add_resources(carried_food, carried_wood, carried_gold)
			returning_to_base = false
			target_building = null
			carried_food = 0
			carried_wood = 0
			carried_gold = 0
			
			if target_tree:
				move_to(target_tree.global_position)
			if target_gold_ore:
				move_to(target_gold_ore.global_position)
			if target_farm:
				move_to(target_farm.global_position)
				
			gathering = true

	if gathering and target_tree:
		if global_position.distance_to(target_tree.global_position) < 24.0:
			animation.play("HarvestWood")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_wood()
	
	if gathering and target_gold_ore:
		if global_position.distance_to(target_gold_ore.global_position) < 24.0:
			animation.play("HarvestRock")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_gold()
				
	if gathering and target_farm:
		if global_position.distance_to(target_farm.global_position) < 24.0:
			animation.play("HarvestRock")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_food()
				
	if is_combat_unit:
		attack_timer -= delta
		
		if combat_target and is_combat_target_valid(combat_target):
			
			var distance
			
			if combat_target is Building:
				var tile_size := 16
				var building_radius = (combat_target.size * tile_size) / 2.0
				var direction := global_position.direction_to(combat_target.global_position)
				var edge_position = combat_target.global_position - direction * building_radius
				distance = global_position.distance_to(edge_position)
				
			else:
				distance = global_position.distance_to(combat_target.global_position)
			
			if distance <= attack_range:
				velocity = Vector2.ZERO
				
				if animation.has_animation("Combat"):
					sprite.flip_h = combat_target.global_position.x < global_position.x
					animation.play("Combat")
				
				if attack_timer <= 0:
					move_and_slide()
					attack_target()
					attack_timer = attack_cooldown
					
	if not nav_agent.is_navigation_finished():
		var next_position = nav_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		if abs(velocity.x) > abs(velocity.y):
			if !gathering and !building and !terraforming and !combat_target:
				animation.play("WalkRight")
				activity_sound.stop()
				sprite.flip_h = velocity.x < 0
		else:
			if !gathering and !building and !terraforming and !combat_target:
				animation.play("Idle")
				activity_sound.stop()
				sprite.flip_h = false
	else:
		if velocity != Vector2.ZERO:
			move_and_slide()
		velocity = Vector2.ZERO
		
func is_mouse_over_shape(collision_shape: CollisionShape2D, mouse_position: Vector2) -> bool:
	var shape = collision_shape.shape
	var global_position = collision_shape.global_position
	
	var radius = shape.radius
	
	return global_position.distance_to(mouse_position) <= radius
				
func attack_target():
	if combat_target == null or not is_combat_target_valid(combat_target):
		combat_target = null
		
		return
		
	if is_ranged_unit:
		nav_agent.set_target_position(global_position)
		shoot_projectile_at(combat_target)
	else:
		combat_target.take_damage(attack_damage, self)
	
func take_damage(amount: int, attacker = null):
	if attacker == null:
		return
		
	health -= amount
	emit_signal("health_changed", health)
	play_activity_sound(4)
	
	if not health_bar.visible:
		health_bar.visible = true
		
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", health, 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if is_combat_unit and  combat_target == null and attacker != null and attacker != self:
		combat_target = attacker
		move_to(attacker.global_position)
	
	if health <= 0:
		attacker.combat_target = null
		die()
		
func stop_building():
	building = false
	target_building = null
	animation.play("Idle")
	
	await get_tree().process_frame
	
	for body in combat_detection_zone.get_overlapping_bodies():
		if body is ConstructionSite and body.player_id == player_id:
			set_build_target(body)
				
			return
	
func shoot_projectile_at(target):
	if not projectile_scene or not target:
		return
		
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.target = target
	projectile.speed = projectile_speed
	projectile.damage = attack_damage
	projectile.source = self
	get_tree().get_root().add_child(projectile)
		
func die():
	sound_manager.play_sound(activity_sounds[5])
	
	var bones = bones_scene.instantiate()
	bones.global_position = global_position
	get_tree().current_scene.add_child(bones)
	
	if Game.current_mode == "SURVIVAL":
		var resourceToGive = RandomNumberGenerator.new()
		resourceToGive.randomize()
		var number = resourceToGive.randi_range(0, 2)
		
		if number == 0:
			add_resources(10, 0, 0)
		elif number == 1:
			add_resources(0, 10, 0)
		else: 
			add_resources(0, 0, 10)
		
	queue_free()
	
func is_combat_target_valid(target):
	if target is Unit or target is Building:
		return true
		
	return false
	
func play_select_sound():
	if select_sounds.size() > 0:
		select_sound.stop()
		var index = randi() % select_sounds.size()
		select_sound.stream = select_sounds[index]
		select_sound.play()
		
func play_attack_sound():
	var all_units = get_tree().get_nodes_in_group("units")
				
	for unit in all_units:
		if unit.selected:
			if unit == self:
				if attack_sounds.size() > 0:
					attack_sound.stop()
					var index = randi() % attack_sounds.size()
					attack_sound.stream = attack_sounds[index]
					attack_sound.play()
					
			break
		
func play_move_sound():
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
		
func play_activity_sound(activityIndex: int):
		if activity_sound_timer >= activity_sound_interval:
			if activityIndex >= 0 and activityIndex < activity_sounds.size():
				activity_sound_timer = 0.0
				activity_sound.stream = activity_sounds[activityIndex]
				activity_sound.stream.loop = false
				activity_sound.pitch_scale = randf_range(0.8, 1.3)
				activity_sound.play()
	
func set_gather_target(object):
	if not can_gather_resources:
		print("Unit cannot gather resources")
		
		return
	
	if object is TreeObject:
		target_tree = object
		
	if object is GoldOreObject:
		target_gold_ore = object
		
	if object is Farm:
		target_farm = object
		
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
		play_activity_sound(1)
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
		play_activity_sound(2)
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
		
func collect_food():
	if not target_farm:
		return
		
	if target_farm.has_method("gather"):
		if !target_farm.isOccupied or target_farm.unit == self:
				
			target_farm.occupy(self)
				
			play_activity_sound(2)
			var gathered_food = target_farm.gather(1)
			carried_food += gathered_food
				
			if carried_food >= max_gather_amount:
				move_to(find_closest_collection_point())
				returning_to_base = true
				gathering = false
				target_farm.unOccupy()
				
		else:
			print("Food from farm cannot be gathered")
			gathering = false
			target_farm = null
			animation.play("Idle")

func find_closest_collection_point():
	var closest_position = Vector2.ZERO
	var closest_distance = INF
	
	for building in get_tree().get_nodes_in_group("buildings"):
		
		if building is not ConstructionSite:
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
	
func attempt_terraform_tile(coordinates: Vector2i) -> bool:
	var tile_data = tilemap.get_cell_atlas_coords(coordinates)
	
	if tile_data == TileTypes.ATLAS_COORDS["GRASS"] or tile_data == TileTypes.ATLAS_COORDS["DIRT"]:
		var tilemap_layer = get_tree().get_root().get_node("World/TileMapLayer")
		var tileset = tilemap_layer.tile_set
		var tile_size = tileset.get_tile_size()
		var tile_size_f = Vector2(tile_size.x, tile_size.y)
		set_terraform_target(tilemap.map_to_local(coordinates) + tile_size_f / 2, coordinates)
						
		return true
	else: 
		target_tile = null
		target_tile_coords = null
		terraforming = false
		terraforming_cancelled = true
						
		return false
	
func set_terraform_target(moveLocation: Vector2, coords: Vector2i):
	move_to(moveLocation)
	target_tile = coords
	target_tile_coords = moveLocation
	
func start_terraforming(coords: Vector2i):
	if terraforming:
		return
		
	terraforming = true
	terraforming_cancelled = false
	
	terraforming_frontier = [coords]
	explored = { coords: true }
	
	
	_animation_and_sound_start()
	terraform_step()
	
func terraform_step():
	if terraforming_cancelled or terraforming_frontier.is_empty():
		terraforming = false
		terraforming_frontier.clear()
		explored.clear()
		target_tile = null
		target_tile_coords = null
		animation.play("Idle")
		activity_sound.stop()
		is_playing_activity_sound = false
		return
	
	var current_coords = terraforming_frontier.pop_front()
	var terraform_delay = randf_range(2.0, 6.0)
	await get_tree().create_timer(terraform_delay).timeout
	
	if terraforming_cancelled:
		terraforming = false
		return

	var atlas_coords = TileTypes.ATLAS_COORDS[player_owner.faction.faction_tile]
	tilemap.set_cell(current_coords, 0, atlas_coords)

	var adjacent_offsets = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]
	adjacent_offsets.shuffle()

	for offset in adjacent_offsets:
		var next_coords = current_coords + offset
		if not explored.has(next_coords) and attempt_terraform_tile(next_coords):
			terraforming_frontier.append(next_coords)
			explored[next_coords] = true

	terraform_step()

func _animation_and_sound_start():
	animation.play("Terraform")
	if not is_playing_activity_sound:
		activity_sound.play()
		is_playing_activity_sound = true

func _on_combat_detection_zone_body_entered(body) -> void:
	if is_combat_unit and !combat_target:
		if body is Unit:
			if body != self and body.player_id != player_id:
				play_attack_sound()
				combat_target = body
				move_to(body.global_position)
				combat_follow_timer.start()
					

func _on_combat_follow_timer_timeout() -> void:
	var no_enemies_detected = true
	
	if combat_target and is_instance_valid(combat_target):
		move_to(combat_target.global_position)
	else:
		for body in combat_detection_zone.get_overlapping_bodies():
			if body is Unit and body != self and body.player_id != player_id:
				play_attack_sound()
				combat_target = body
				move_to(body.global_position)
				no_enemies_detected = false
				
				return
				
		if no_enemies_detected:
			combat_follow_timer.stop()

func _on_combat_detection_zone_body_exited(body) -> void:
	if body == combat_target:
		combat_target = null
		
func add_resources(food = 0, wood = 0, gold = 0):
	var popupText = popup.instantiate()
	world.add_child(popupText)
	popupText.global_position = global_position + Vector2(-20, 0)
	popupText.show_value(food, wood, gold, false)
	
	Game.food += food
	Game.wood += wood
	Game.gold += gold
