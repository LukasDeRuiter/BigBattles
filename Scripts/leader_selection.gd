extends Node2D

func _on_barbarian_leader_button_pressed() -> void:
	Game.selected_leader = "barbarian"
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_alien_leader_button_pressed() -> void:
	Game.selected_leader = "alien"
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
