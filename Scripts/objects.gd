extends Node2D

@onready var tree = preload("res://Scenes/objects/tree.tscn")
@onready var gold_ore = preload("res://Scenes/objects/gold_ore.tscn")
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
	for i in range(100):
		var xCoordinate = (randi() % int(grid_size.x))
		var yCoordinate = (randi() % int(grid_size.y))
		var grid_position = Vector2(xCoordinate, yCoordinate)
		
		if not grid_position in positions:
			positions.append(grid_position)
	
	for loopPosition in positions:
		var instance
		
		if randi() % 10 == 0:
			instance = gold_ore.instantiate()
			
		else:
			instance = tree.instantiate()
			
		instance.position = loopPosition * tile_size + Vector2(tile_size, tile_size) / 2
		grid[position.x][position.y] = OBSTACLE
		add_child(instance)
		instance.add_to_group("objects", true)
		
func _input(event):
	pass
