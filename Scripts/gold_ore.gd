extends StaticBody2D

class_name GoldOreObject

@onready var bar = $ProgressBar
@onready var grid = get_tree().get_root().get_node("World/Grid") 

var gold_amount = 100

func  _ready() -> void:
	bar.max_value = gold_amount
	bar.value = gold_amount
	bar.visible = false

func gather(amount: int):
	var gathered = min(amount, gold_amount)
	gold_amount -= gathered
	
	if not bar.visible:
		bar.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", gold_amount, 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if gold_amount <= 0:
		var grid_pos = grid.world_to_grid(position)
		grid.unregister_gold_ore(grid_pos)
		queue_free()
	
	return gathered
