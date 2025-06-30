extends CanvasLayer

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
