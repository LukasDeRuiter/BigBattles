extends Button

@export var building_data: BuildingData

@onready var cmd_manager = $"../../../CommandManager"

func _on_button_pressed():
	var is_same = cmd_manager.preview_mode and cmd_manager.selected_building_data == building_data
	
	cmd_manager.set_preview_active(!is_same, building_data)

func _on_pressed() -> void:
	_on_button_pressed()
