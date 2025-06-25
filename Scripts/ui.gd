extends CanvasLayer

@onready var food_label = $FoodLabel
@onready var wood_label = $WoodLabel
@onready var gold_label = $GoldLabel
@onready var fps_label = $fpsCounter
@onready var command_manager = $"../CommandManager"
	
func _process(delta):
	food_label.text = "Food: " + str(Game.food)
	wood_label.text = "Wood: " + str(Game.wood)
	gold_label.text = "Gold: " + str(Game.gold)
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
