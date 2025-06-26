extends RichTextLabel

var travel = Vector2(0, -50)
var duration = 1
var spread = PI / 2

func show_value(food, wood, gold, crit):
	var tween = create_tween()
	var text = ""
	
	if food != 0:
		text += "[color=red]+ " + str(food) + " food[/color]\n"
	if wood != 0:
		text += "[color=green]+ " + str(wood) + " wood[/color]\n"
	if gold != 0:
		text += "[color=gold]+ " + str(gold) + " gold[/color]\n"
		
	self.set("bbcode_enabled", true)
	bbcode_enabled = true
	self.text = text
	
	pivot_offset = size / 4
	
	var movement = travel.rotated(randi_range(-spread / 2, spread / 2))
	
	tween.tween_property(self, "position", position + movement, duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
	if crit == true:
		modulate = Color(1, 0, 0)
		scale = scale * 2
		tween.tween_property(self, "scale", scale, 0.4)
	
	tween.play()
	tween.tween_callback(self.queue_free)
		
