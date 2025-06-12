extends Node

@onready var spawn = preload("res://Scenes/spawn_unit.tscn")

var wood = 0

func spawnUnit():
	var path = get_tree().get_root().get_node("World/UI")
	var spawnUnit =  spawn.instantiate()
	path.add_child(spawnUnit)
