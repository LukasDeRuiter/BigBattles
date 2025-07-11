extends Resource

class_name Squad

var units: Array[Node] = []
var waypoints: PackedVector2Array = PackedVector2Array()
var leader: Node
var formation_offsets: Dictionary

func assign_path(path: PackedVector2Array) -> void:
	waypoints = path.duplicate()
	for unit in units:
		unit.current_wp_index = 0
