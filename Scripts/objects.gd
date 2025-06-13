extends Node2D

@onready var tree = preload("res://Scenes/tree.tscn")
@onready var house = preload("res://Scenes/coin_house.tscn")

var tile_size = 16
var grid_size = Vector2(160, 160)
var grid = []

enum { OBSTACLE, COLLECTABLE, RESOURCE }

func _ready():
	for x in range(grid_size.x):
		grid.append([])
		
		for y in range(grid_size.y):
			grid[x].append(null)
		
	var positions = []
	for i in range(50):
		var xCoordinate = (randi() % int(grid_size.x))
		var yCoordinate = (randi() % int(grid_size.y))
		var grid_position = Vector2(xCoordinate, yCoordinate)
		
		if not grid_position in positions:
			positions.append(grid_position)
	
	for loopPosition in positions:
		var new_tree = tree.instantiate()
		new_tree.set_position(loopPosition * tile_size)
		grid[position.x][position.y] = OBSTACLE
		add_child(new_tree)
		
func _input(event):
	pass
	## if event.is_action_pressed("LeftClick"):
		## var mouse_position = get_global_mouse_position()
		## var multiX = int(round(mouse_position.x) / tile_size)
		## var numberX = multiX * tile_size
		## var multiY = int(round(mouse_position.y) / tile_size)
		## var numberY = multiY * tile_size
		## var new_position = Vector2(multiX, multiY)
		## var around = false
		
		## for i in range(tile_size):
			## if (grid[multiX + i][multiY] != null) or (grid[multiX - i][multiY] != null) or (grid[multiX][multiY + i] != null) or (grid[multiX][multiY - i] != null):
				## around = true
				
		## if grid[multiX][multiY] == null:
			## if around == false:
				## var new_house = house.instantiate()
				## new_house.set_position(new_position * tile_size)
				## grid[multiX][multiY] = OBSTACLE
				## add_child(new_house)
