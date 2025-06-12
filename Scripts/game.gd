extends Node

@onready var spawn = preload("res://Scenes/spawn_unit.tscn")

var wood = 0
var coin = 0

func spawnUnit(position):
	var path = get_tree().get_root().get_node("World/UI")
	var hasSpawn = false
	
	for count in path.get_child_count():
		if "SpawnUnit" in path.get_child(count).name:
			hasSpawn = true
			
	if hasSpawn == false:
		var spawnUnit =  spawn.instantiate()
		spawnUnit.housePosition = position
		path.add_child(spawnUnit)
