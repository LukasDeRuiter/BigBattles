extends CanvasLayer

@onready var label = $Label

func _process(delta):
	label.text = "Wood: " + str(Game.wood)
