extends Node

@onready var spawn = preload("res://Scenes/spawn_unit.tscn")

var food = 0
var wood = 0
var gold = 0

var fps = Engine.get_frames_per_second()

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
