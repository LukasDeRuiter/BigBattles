extends StaticBody2D

var mouseEntered = false
var selected = false
var training_queue: Array[UnitData] = []
var current_train_time: float = 0.0
var trainable_units = []

@onready var select = get_node("Selected")
@onready var command_manager = $"../../CommandManager"

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
			
			if selected == true:
				command_manager.select_building(self)
			else: 
				command_manager.deselect_building()

func _on_mouse_entered():
	mouseEntered = true

func _on_mouse_exited():
	mouseEntered = false
	
