extends CanvasLayer

@onready var label = $Label
@onready var command_manager = $"../CommandManager"
	
func _process(delta):
	label.text = "Wood: " + str(Game.wood)
