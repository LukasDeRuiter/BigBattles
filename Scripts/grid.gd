extends Node2D

const TILE_SIZE = Vector2i(16, 16)
const TileTypes = preload("res://Scripts/enums/tile_types.gd")

var grid_data = {}
var tilemap: TileMapLayer = null

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
	
func block_tile_navigation(grid_position: Vector2i) -> void:
	var atlas_coords = TileTypes.ATLAS_COORDS["WATER"]
	tilemap.set_cell(grid_position, 0, atlas_coords)
	
func unblock_tile(grid_position: Vector2i) -> void:
	if grid_data.has(grid_position):
		grid_data[grid_position]["blocked"] = false
		
func add_navigation_to_tile(grid_position: Vector2i) -> void:
	var atlas_coords = TileTypes.ATLAS_COORDS["DIRT"]
	tilemap.set_cell(grid_position, 0, atlas_coords)
	
func set_tile_data(grid_position: Vector2i, data: Dictionary) -> void:
	grid_data[grid_position] = data
	
func get_tile_data(grid_position: Vector2i) -> Dictionary:
	return grid_data.get(grid_position, {})
