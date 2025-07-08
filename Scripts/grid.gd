extends Node2D

const TILE_SIZE = Vector2i(16, 16)
const TileTypes = preload("res://Scripts/enums/tile_types.gd")

var grid_data = {}
var tilemap: TileMapLayer = null

var trees := {}
var gold_ores := {}
var farms := {}
var wall_tiles := {}

func _ready() -> void:
	tilemap = get_tree().get_root().get_node("World/TileMapLayer")

func world_to_grid(world_position: Vector2) -> Vector2i:
	return Vector2i(floor(world_position.x / TILE_SIZE.x), floor(world_position.y / TILE_SIZE.y))
	
func grid_to_world(grid_position: Vector2i) -> Vector2:
	return Vector2i(grid_position.x * TILE_SIZE.x, grid_position.y * TILE_SIZE.y)
	
func is_walkable(grid_position: Vector2i) -> bool:
	if grid_position in grid_data:
		return !grid_data[grid_position].get("blocked", false)
	
	return true

func block_tile(grid_position: Vector2i) -> void:
	if not grid_data.has(grid_position):
		grid_data[grid_position] = {}
		
	grid_data[grid_position]["blocked"] = true
	
func block_tile_navigation(grid_position: Vector2i, tile_type: String = "GRASS_BLOCKED") -> void:
	var atlas_coords = TileTypes.ATLAS_COORDS[tile_type]
	tilemap.set_cell(grid_position, 0, atlas_coords)
	
func unblock_tile(grid_position: Vector2i) -> void:
	if grid_data.has(grid_position):
		grid_data[grid_position]["blocked"] = false
		
func add_navigation_to_tile(grid_position: Vector2i, tile_type: String = "GRASS") -> void:
	var atlas_coords = TileTypes.ATLAS_COORDS[tile_type]
	tilemap.set_cell(grid_position, 0, atlas_coords)
	
func set_tile_data(grid_position: Vector2i, data: Dictionary) -> void:
	grid_data[grid_position] = data
	
func get_tile_data(grid_position: Vector2i) -> Dictionary:
	return grid_data.get(grid_position, {})
	
	
func register_tree(pos: Vector2i, tree):
	trees[pos] = tree

func unregister_tree(pos: Vector2i):
	trees.erase(pos)
	
func register_gold_ore(pos: Vector2i, gold_ore):
	gold_ores[pos] = gold_ore

func unregister_gold_ore(pos: Vector2i):
	gold_ores.erase(pos)
	
func register_farm(pos: Vector2i, farm):
		for x in range(farm.size.x):
			for y in range(farm.size.y):
				farms[pos + Vector2i(x, y)] = farm

func unregister_farms(pos: Vector2i, farm):
		for x in range(farm.size.x):
			for y in range(farm.size.y):
				farms.erase(pos + Vector2i(x, y))
				
func register_wall(position: Vector2i, wall: Wall):
	wall_tiles[position] = wall
	
func unregister_wall(position: Vector2i):
	wall_tiles.erase(position)
	
func is_wall_at(position: Vector2i):
	return wall_tiles.has(position)
	
func get_wall_at(position: Vector2i):
	return wall_tiles.get(position, null)
