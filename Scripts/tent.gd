extends StaticBody2D

var mouseEntered = false
var selected = false
var training_queue: Array[UnitData] = []
var current_train_time: float = 0.0

@onready var select = get_node("Selected")

func _process(delta: float):
	select.visible = selected

func selectBuilding():
	selected = true
	
func deselectBuilding():
	selected = false

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == true:
			selected = !selected
			
			## if selected == true:
				## Game.spawnUnit(position)

func _on_mouse_entered():
	mouseEntered = true

func _on_mouse_exited():
	mouseEntered = false

func queue_train_unit(unit: UnitData):
	training_queue.append(unit)
	
func spawn_unit(unit: UnitData):
	var instance = unit.unit_scene.instantiate()
	instance.global_position = global_position + Vector2(32, 0)
	get_tree().current_scene.add_child(instance)
