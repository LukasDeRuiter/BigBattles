extends Area2D

var speed: float = 200.0
var damage: int = 10
var target
var source

func _ready():
	connect("area_entered", _on_area_entered)
	
func _process(delta):
	if not target or not is_instance_valid(target):
		queue_free()
		
		return
		
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	
	rotation = direction.angle()
	
	
func _on_area_entered(area):
	if area == target and area.has_method("take_damage"):
		area.take_damage(damage, source)
		queue_free()
