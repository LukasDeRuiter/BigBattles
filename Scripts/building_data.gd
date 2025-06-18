extends Resource

class_name BuildingData

@export var name: String
@export var building_scene: PackedScene
@export var preview_scene: PackedScene
@export var trainable_units: Array[UnitData]
@export var size: Vector2i = Vector2i(1, 1)
@export var is_collection_point = false
