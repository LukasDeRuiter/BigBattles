extends Node2D

@onready var tree = preload("res://Scenes/objects/tree.tscn")
@onready var gold_ore = preload("res://Scenes/objects/gold_ore.tscn")
@onready var house = preload("res://Scenes/coin_house.tscn")

var tile_size = 16
var grid_size = Vector2(160, 160)
var grid = []
var tilemap: TileMapLayer = null

const TileTypes = preload("res://Scripts/enums/tile_types.gd")

enum { OBSTACLE, COLLECTABLE, RESOURCE }

func _ready():
	tilemap = get_tree().get_root().get_node("World/TileMapLayer")
	var tilemap_bounds = tilemap.get_used_rect()
	
	var world_rect = Rect2(
	tilemap_bounds.position * tilemap.tile_set.tile_size,
	tilemap_bounds.size * tilemap.tile_set.tile_size
)
	
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
				
			var value = noise.get_noise_2d(x, y)
			var tile_type = "GRASS"
	
			if value > -0.1:
				tile_type = "GRASS"
			elif value > -0.3:
				tile_type = "DIRT"
			else:
				tile_type = "WATER"
			
			var atlas_coords = TileTypes.ATLAS_COORDS[tile_type]
			tilemap.set_cell(Vector2i(x, y), 0, atlas_coords)
			if tile_type == "GRASS":
				if value > 0.2:
					var tree_instance = tree.instantiate()
					tree_instance.position = Vector2(x, y) * tile_size + Vector2(tile_size, tile_size) / 2
					add_child(tree_instance)
					tree_instance.add_to_group("objects", true)
				elif value < -0.4:
					var gold_instance = gold_ore.instantiate()
					gold_instance.position = Vector2(x, y) * tile_size + Vector2(tile_size, tile_size) / 2
					add_child(gold_instance)
					gold_instance.add_to_group("objects", true)
	
		
func _input(event):
	pass
