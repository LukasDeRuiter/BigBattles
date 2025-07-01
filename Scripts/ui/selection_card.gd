extends Control

@onready var icon = $TextureRect
@onready var health_bar = $ProgressBar

var unit

func setup(data_reference):
	unit = data_reference
	icon.texture = data_reference.icon
	health_bar.min_value = 0
	health_bar.max_value = data_reference.max_health
	health_bar.value = data_reference.health
	
	data_reference.health_changed.connect(_on_unit_health_changed)
	data_reference.tree_exited.connect(_on_unit_removed)
	
func _on_unit_health_changed(new_health):
	health_bar.value = new_health
	
func _on_unit_removed():
	queue_free()
