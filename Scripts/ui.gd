extends CanvasLayer

@onready var label = $Label
@onready var command_manager = $"../CommandManager"
@onready var btn_place_building = $PlaceBuilding

func _ready() -> void:
	btn_place_building.connect("pressed", Callable(self, "_on_place_building_pressed"))
	
func _process(delta):
	label.text = "Wood: " + str(Game.wood)

func _on_place_building_pressed() -> void:
	var new_state = !command_manager.preview_mode
	command_manager.set_preview_active(new_state)
