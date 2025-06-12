extends StaticBody2D

var mouseEntered = false
var selected = false

@onready var select = get_node("Selected")

func _process(delta: float):
	select.visible = selected

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if mouseEntered == true:
			selected = !selected
			
			if selected == true:
				Game.spawnUnit(position)

func _on_mouse_entered():
	mouseEntered = true

func _on_mouse_exited():
	mouseEntered = false
