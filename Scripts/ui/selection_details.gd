extends Control

@onready var icon = $TextureRect
@onready var health_bar = $ProgressBar
@onready var name_label = $NameLabel

var unit

func setup(data_reference):
	unit = data_reference
	icon.texture = data_reference.icon
	name_label.text = data_reference.displayName
	health_bar.min_value = 0
	health_bar.max_value = data_reference.max_health
	health_bar.value = data_reference.health
	
	if data_reference is Building:
		data_reference.connect("training_queue_updated", Callable(self, "_on_training_queue_updated"))
		
		for unit in data_reference.training_queue:
			var icon_texture = unit.icon
			var icon_rect = TextureRect.new()
			icon_rect.texture = icon_texture
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_rect.custom_minimum_size = Vector2(32, 32)
			$UnitQueue.add_child(icon_rect)

		$UnitQueue.visible = true
	
	data_reference.health_changed.connect(_on_unit_health_changed)
	data_reference.tree_exited.connect(_on_unit_removed)
	
func _on_unit_health_changed(new_health):
	health_bar.value = new_health
	
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", new_health, 0.1).set_trans(Tween.TRANS_LINEAR)
	
func _on_unit_removed():
	visible = false
	
func _on_training_queue_updated(building):
	for child in $UnitQueue.get_children():
		child.queue_free()
		
	for unit in building.training_queue:
			var icon_texture = unit.icon
			var icon_rect = TextureRect.new()
			icon_rect.texture = icon_texture
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_rect.custom_minimum_size = Vector2(32, 32)
			$UnitQueue.add_child(icon_rect)
	
