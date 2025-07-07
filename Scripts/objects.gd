extends Node2D

@onready var tree = preload("res://Scenes/objects/tree.tscn")
@onready var gold_ore = preload("res://Scenes/objects/gold_ore.tscn")
@onready var house = preload("res://Scenes/coin_house.tscn")
@onready var grid_node = get_tree().get_root().get_node("World/Grid") 

var tile_size = 16
var grid_size = Vector2(160, 160)
var grid = []
var tilemap: TileMapLayer = null

const TileTypes = preload("res://Scripts/enums/tile_types.gd")

enum { OBSTACLE, COLLECTABLE, RESOURCE }

func _ready():
	pass
	
func _input(event):
	pass
