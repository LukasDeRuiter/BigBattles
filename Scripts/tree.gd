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
	if currentTime <=  0:
		treeChopped()


func _on_chop_area_body_entered(body):
	if "Unit" in body.name:
		units += 1
		startChopping


func _on_chop_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_timer_timeout():
	currentTime -= 1 * units

func startChopping():
	timer.start()

func treeChopped():
	queue_free()
