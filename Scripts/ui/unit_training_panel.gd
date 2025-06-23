extends Control

@onready var button_container = $VBoxContainer
@onready var button_template = button_container.get_node("UnitButtonTemplate")

var active_building = null

func show_for_building(building):
	active_building = building
	clear_buttons()
	
	if building is not ConstructionSite:
		if building.trainable_units:
			for unit_data in building.trainable_units:
				print(unit_data.name)
				var btn = button_template.duplicate()
				btn.text = unit_data.name
				btn.icon = unit_data.icon
				btn.visible = true
				btn.pressed.connect(func():
					building.queue_train_unit(unit_data)
					)
				button_container.add_child(btn)
		
func clear_buttons() -> void:
	for child in button_container.get_children():
		if child != button_template:
			child.queue_free()
			
func hide_panel() -> void:
	active_building = null
	clear_buttons()
	hide()
