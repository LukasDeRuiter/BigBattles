extends Node2D

var units =  []
var buildings = []

@onready var command_manager = $CommandManager
@onready var pause_menu = $PauseMenu

func _ready():
	get_units()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
			
func pause_game():
	get_tree().paused = true
	pause_menu.visible = true
	
func resume_game():
	get_tree().paused = false
	pause_menu.visible = false
	
func get_units():
	units = null
	units = get_tree().get_nodes_in_group("units")

func get_buildings():
	buildings = null
	buildings = get_tree().get_nodes_in_group("buildings")

func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area = []
	
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	
	var ut = get_units_in_area(area)
	var allUnits = get_tree().get_nodes_in_group("units")
	
	for u in allUnits:
		u.set_selected(false)
		
	var buildings = $Buildings.get_children()
	for building in buildings :
		building.deselectBuilding()
		
	if ut.size() > 0:
		for u in ut:
			u.set_selected(!u.selected)
			ut[0].play_select_sound()
			command_manager.deselect_building()
	else:
		var building = get_building_in_area(area)
		if building:
			command_manager.select_building(building)
		else: 
			command_manager.deselect_building()
		
	
func get_units_in_area(area):
	var u = []
	
	## Check if units are inside the selection box
	for unit in get_tree().get_nodes_in_group("units"):
		if (unit.position.x > area[0].x) and (unit.position.x < area[1].x):
			if (unit.position.y > area[0].y) and (unit.position.y < area[1].y):
				u.append(unit)
				pass
	
	return u;
	
func get_building_in_area(area):
	var buildings = $Buildings.get_children()
	for building in buildings :
		var position = building.global_position
		if (position.x > area[0].x and position.x < area[1].x and position.y > area[0].y and position.y < area[1].y):
			return building
			
	return null
			
