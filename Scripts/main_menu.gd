extends Node2D

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_start_survival_button_pressed() -> void:
	Game.current_mode = "SURVIVAL"
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_start_skirmish_button_pressed() -> void:
	Game.current_mode = "SKIRMISH"
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
