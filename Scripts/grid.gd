extends Node2D

const TILE_SIZE = Vector2i(16, 16)

var grid_data = {}

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
	
func unblock_tile(grid_position: Vector2i) -> void:
	if grid_data.has(grid_position):
		grid_data[grid_position]["blocked"] = false
	
func set_tile_data(grid_position: Vector2i, data: Dictionary) -> void:
	grid_data[grid_position] = data
	
func get_tile_data(grid_position: Vector2i) -> Dictionary:
	return grid_data.get(grid_position, {})
