extends Control

@onready var button_container = $VBoxContainer
@onready var button_template = button_container.get_node("UnitButtonTemplate")
@onready var tooltip = $"../../ToolTip"

var active_building = null

func show_for_building(building):
	active_building = building
	clear_buttons()
	
	if building is not ConstructionSite:
		if building.trainable_units:
			for unit_data in building.trainable_units:
				var btn = button_template.duplicate()
				btn.icon = unit_data.icon
				btn.visible = true
				
				btn.pressed.connect(func():
					building.queue_train_unit(unit_data)
					)
					
				btn.mouse_entered.connect(func():
					var tooltip_title = unit_data.name
					var tooltip_description = unit_data.description
					tooltip.show_tooltip(tooltip_title, tooltip_description)
					)
					
				btn.mouse_exited.connect(func():
					tooltip.hide_tooltip()
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
