extends StaticBody2D

class_name Building

signal health_changed(new_health)

@export var building_sounds: Array[AudioStream]
@export var player_id: int

var displayName: String
var mouseEntered = false
var selected = false
var training_queue: Array[UnitData] = []
var current_train_time: float = 0.0
var trainable_units = []
var rally_point: Vector2
var health: int = 100
var max_health: int = 100
var size: Vector2i = Vector2i(1, 1)
var placed_grid_position: Vector2i
var icon: Texture2D

var is_collection_point = false
var is_unit_train_point = false

var popup = preload("res://Scenes/popup.tscn")

@onready var select = get_node("Selected")
@onready var command_manager = $"../../CommandManager"
@onready var rally_flag = $RallyFlag
@onready var progress_bar = $ProgressBar
@onready var health_bar = $HealthBar
@onready var grid = get_tree().get_root().get_node("World/Grid")
@onready var sound_manager = get_tree().get_root().get_node("World/SoundManager") 
@onready var building_sound = get_node("BuildingSound")

func _ready():
	add_to_group("buildings", true)
	rally_point = global_position
	
	progress_bar.min_value = 0
	progress_bar.max_value = 1
	progress_bar.value = 0
	progress_bar.visible = false
	
	health_bar.min_value = 0
	health_bar.max_value = health
	health_bar.value = health
	health_bar.visible = false

func _process(delta: float):
	select.visible = selected
	rally_flag.visible = selected
	rally_flag.global_position = rally_point

	if training_queue.size() > 0:
		var unit_to_train = training_queue[0]
		current_train_time -= delta

		progress_bar.visible = true
		progress_bar.value = 1.0 - (current_train_time / unit_to_train.train_time)

		if current_train_time <= 0:
			training_queue.pop_front()
			spawn_unit(unit_to_train)
			
			if training_queue.size() > 0:
				current_train_time = training_queue[0].train_time
			else:
				progress_bar.visible = false
				progress_bar.value = 0
	else:
		progress_bar.visible = false
		progress_bar.value = 0

func selectBuilding():
	selected = true
	
func deselectBuilding():
	selected = false
	
func set_selected(value):
	selected = value
	select.visible = value
	
	if selected == true:
		command_manager.select_building(self)
	else: 
		command_manager.deselect_building()

func _on_mouse_entered():
	mouseEntered = true

func _on_mouse_exited():
	mouseEntered = false

func queue_train_unit(unit: UnitData):
	training_queue.append(unit)
	
	if training_queue.size() == 1:
		current_train_time = unit.train_time
	
func spawn_unit(unit: UnitData):
	var instance = unit.unit_scene.instantiate()
	var unitPath = get_tree().get_root().get_node("World/Units")
	
	instance.name = unit.name
	instance.player_id = player_id
	instance.position = global_position + Vector2(0, 32)
	instance.target = rally_point
	instance.data = unit
	
	unitPath.add_child(instance)
	instance.move_to(rally_point)

func add_resources(food, wood, gold):
	var popupText = popup.instantiate()
	add_child(popupText)
	popupText.global_position = global_position + Vector2(-20, 0)
	popupText.show_value(food, wood, gold, false)
	
	Game.food += food
	Game.wood += wood
	Game.gold += gold

func take_damage(amount: int, attacker: Unit = null):
	health -= amount
	emit_signal("health_changed", health)
	play_building_sound(0, true)
	
	if not health_bar.visible:
		health_bar.visible = true
		
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", health, 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if health <= 0:
		attacker.combat_target = null
		die()
		
func die():
	if self is Farm:
		grid.unregister_farm(placed_grid_position, self)
		
	for x in size.x:
		for y in size.y:
			grid.unblock_tile(placed_grid_position + Vector2i(x, y))
			grid.add_navigation_to_tile(placed_grid_position + Vector2i(x, y))
			
	
	sound_manager.play_sound(building_sounds[1])
	queue_free()

func play_building_sound(activityIndex: int, pitch: bool = false):
	building_sound.stream = building_sounds[activityIndex]
	building_sound.stream.loop = false
	
	if pitch:
		building_sound.pitch_scale = randf_range(0.8, 1.3)
		
	building_sound.play()
	
