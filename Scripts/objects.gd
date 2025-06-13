extends Node2D

@onready var tree = preload("res://Scenes/tree.tscn")
@onready var house = preload("res://Scenes/coin_house.tscn")

var tile_size = 16
var grid_size = Vector2(160, 160)
var grid = []

func _ready():
	for x in range(grid_size.x):
		grid.append([])
		
		for y in range(grid_size.y):
			grid[x].append(null)
	
	var new_tree = tree.instantiate()
	add_child(new_tree)
