extends Node2D

@onready var unit = preload("res://Scenes/units/leaders/test/barbarian_leader.tscn")

var housePosition = Vector2(300, 300)

func _on_yes_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var randomPositionX = rng.randi_range(-50, 50)
	var randomPositionY = rng.randi_range(-50, 50)
	
	var unitPath = get_tree().get_root().get_node("World/Units")
	var worldPath = get_tree().get_root().get_node("World")
	var newUnit = unit.instantiate()
	newUnit.position = housePosition + Vector2(randomPositionX, randomPositionY)
	unitPath.add_child(newUnit)
	worldPath.get_units()

func _on_no_pressed():
	var housePath = get_tree().get_root().get_node("World/Buildings")
	
	for count in housePath.get_child_count():
		if housePath.get_child(count).selected == true:
			housePath.get_child(count).selected = false
	
	queue_free()
