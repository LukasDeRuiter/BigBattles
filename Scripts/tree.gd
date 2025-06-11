extends StaticBody2D

var totalTime = 5
var currentTime
var units = 0

@onready var timer = $Timer
@onready var bar = $ProgressBar

func _ready():
	currentTime = totalTime
	bar.max_value = totalTime

func _process(delta):
	bar.value = currentTime
	
	if currentTime <=  0:
		treeChopped()


func _on_chop_area_body_entered(body):
	if "Unit" in body.name:
		units += 1
		startChopping()


func _on_chop_area_body_exited(body):
	if "Unit" in body.name:
		units -= 1
		
		if units <= 0:
			timer.stop()


func _on_timer_timeout():
	var chopSpeed = 1 * units
	currentTime -= chopSpeed
	
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", currentTime, 0.5).set_trans(Tween.TRANS_LINEAR)

func startChopping():
	timer.start()

func treeChopped():
	Game.wood += 1
	queue_free()
