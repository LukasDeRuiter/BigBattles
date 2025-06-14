extends Node2D

var units =  []

func _ready():
	get_units()
	
func get_units():
	units = null
	units = get_tree().get_nodes_in_group("units")

func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area = []
	
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	
	var ut = get_units_in_area(area)
	
	for u in units:
		u.set_selected(false)
	for u in ut:
		u.set_selected(!u.selected)
		
	if ut.size() > 0:
		ut[0].play_select_sound()
		
	
func get_units_in_area(area):
	var u = []
	
	## Check if units are inside the selection box
	for unit in units:
		if (unit.position.x > area[0].x) and (unit.position.x < area[1].x):
			if (unit.position.y > area[0].y) and (unit.position.y < area[1].y):
				u.append(unit)
				pass
	
	return u;
