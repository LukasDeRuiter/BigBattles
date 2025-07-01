extends Control

@onready var icon = $TextureRect
@onready var name_label = $Label
@onready var health_bar = $ProgressBar

var unit

func setup(data_reference):
	name_label.text = "oof"
	unit = data_reference
	icon.texture = data_reference.icon
	name_label.text = data_reference.name
	health_bar.min_value = 0
	health_bar.max_value = data_reference.max_health
	health_bar.value = data_reference.health
	
	data_reference.helath_changed.connect(_on_unit_health_changed)
	data_reference.tree_exited.connect(_on_unit_removed)
	
func _on_unit_health_changed(new_health):
	health_bar.value = new_health
	
func _on_unit_removed():
	queue_free()
