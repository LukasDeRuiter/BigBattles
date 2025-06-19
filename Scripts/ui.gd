extends CanvasLayer

@onready var wood_label = $WoodLabel
@onready var gold_label = $GoldLabel
@onready var command_manager = $"../CommandManager"
	
func _process(delta):
	gold_label.text = "Gold: " + str(Game.gold)
	wood_label.text = "Wood: " + str(Game.wood)
