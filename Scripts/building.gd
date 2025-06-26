extends StaticBody2D

class_name Building

var mouseEntered = false
var selected = false
var training_queue: Array[UnitData] = []
var current_train_time: float = 0.0
var trainable_units = []
var rally_point: Vector2

var is_collection_point = false
var is_unit_train_point = false

var popup = preload("res://Scenes/popup.tscn")

@onready var select = get_node("Selected")
@onready var command_manager = $"../../CommandManager"
@onready var rally_flag = $RallyFlag

func _ready():
	add_to_group("buildings", true)
	rally_point = global_position

func _process(delta: float):
	select.visible = selected
	rally_flag.visible = selected
	rally_flag.global_position = rally_point
	
	if training_queue.size() > 0:
		current_train_time -= delta
		
		if current_train_time <= 0:
			var unit_to_train = training_queue.pop_front()
			spawn_unit(unit_to_train)
			
			current_train_time = unit_to_train.train_time

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
	
	instance.name = unit.name + "_" + str(instance.get_instance_id())
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
