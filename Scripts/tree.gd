extends StaticBody2D

class_name TreeObject

@onready var bar = $ProgressBar

var wood_amount = 100

func  _ready() -> void:
	bar.max_value = wood_amount
	bar.value = wood_amount
	bar.visible = false

func gather(amount: int):
	var gathered = min(amount, wood_amount)
	wood_amount -= gathered
	
	if not bar.visible:
		bar.visible = true
		
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", wood_amount, 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if wood_amount <= 0:
		queue_free()
	
	return gathered
