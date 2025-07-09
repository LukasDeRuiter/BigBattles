extends Control

@onready var command_manager = get_tree().get_root().get_node("World/CommandManager")
@onready var aggressive_stance_button = $AggresiveStance
@onready var guard_stance_button = $GuardStance

func display():
	var stances = command_manager.get_unit_stances()
	
	guard_stance_button.modulate = Color(0.7, 0.7, 0.7)
	aggressive_stance_button.modulate = Color(0.7, 0.7, 0.7)
	
	if stances.size() == 1:
		if stances[0] == "GUARD":
			guard_stance_button.modulate = Color(0.3, 1.0, 0.3)
		elif stances[0] == "AGGRESSIVE":
			aggressive_stance_button.modulate = Color(0.3, 1.0, 0.3)

func _on_aggresive_stance_pressed() -> void:
	command_manager.set_unit_stance("AGGRESSIVE")
	display()


func _on_guard_stance_pressed() -> void:
	command_manager.set_unit_stance("GUARD")
	display()
