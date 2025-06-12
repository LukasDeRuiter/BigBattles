extends StaticBody2D

var POP = preload("res://Scenes/POP.tscn")

var totalTime = 50
var currentTime

@onready var bar = $ProgressBar
@onready var timer = $Timer

func _ready():
	currentTime = totalTime
	bar.max_value = totalTime
	timer.start()

func _process(delta):
	if currentTime <= 0:
		coinsCollected()

func _on_timer_timeout():
	currentTime -= 1
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", currentTime, 0.1).set_trans(Tween.TRANS_LINEAR)
	
func coinsCollected():
	Game.coin += 10
	_ready()
	
	var pop = POP.instantiate()
	add_child(pop)
	pop.show_value(str(10), false)
