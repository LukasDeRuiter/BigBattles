extends Node2D

@onready var unit = preload("res://Scenes/unit.tscn")

func _on_yes_pressed():
	var unitPath = get_tree().get_root().get_node("World/Units")
	var unit1 = unit.instantiate()
	unit1.position = Vector2(200, 200)
	unitPath.add_child(unit1)

func _on_no_pressed():
	queue_free()
